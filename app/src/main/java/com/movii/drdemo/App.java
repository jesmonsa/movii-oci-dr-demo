package com.movii.drdemo;

import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpExchange;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

/**
 * App de demostración DR para Movii.
 * Expone:
 *   GET /        -> página con la región actual y el conteo de escrituras
 *   GET /health  -> "OK" (usado por el Health Check de Traffic Management)
 *   GET /write   -> inserta una fila en MySQL HeatWave
 *   GET /count   -> devuelve el total de filas
 * Configurada por variables de entorno: REGION, DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASS.
 */
public class App {
  static final String REGION  = env("REGION", "unknown");
  static final String DB_HOST = env("DB_HOST", "localhost");
  static final String DB_PORT = env("DB_PORT", "3306");
  static final String DB_NAME = env("DB_NAME", "drdemo");
  static final String DB_USER = env("DB_USER", "admin");
  static final String DB_PASS = env("DB_PASS", "");

  static String env(String k, String d) {
    String v = System.getenv(k);
    return (v == null || v.isEmpty()) ? d : v;
  }

  static String url() {
    return "jdbc:mysql://" + DB_HOST + ":" + DB_PORT + "/" + DB_NAME
        + "?useSSL=true&allowPublicKeyRetrieval=true&connectTimeout=5000";
  }

  public static void main(String[] args) throws Exception {
    initSchema();
    HttpServer s = HttpServer.create(new InetSocketAddress(8080), 0);
    s.createContext("/", App::home);
    s.createContext("/health", e -> respond(e, 200, "OK"));
    s.createContext("/write", App::write);
    s.createContext("/count", App::count);
    s.setExecutor(null);
    System.out.println("Listening on :8080  region=" + REGION);
    s.start();
  }

  static void initSchema() {
    try (Connection c = DriverManager.getConnection(url(), DB_USER, DB_PASS);
         Statement st = c.createStatement()) {
      st.execute("CREATE TABLE IF NOT EXISTS demo_writes ("
          + "id BIGINT AUTO_INCREMENT PRIMARY KEY, "
          + "region VARCHAR(64), "
          + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");
    } catch (Exception ex) {
      System.out.println("initSchema warn: " + ex.getMessage());
    }
  }

  static long rowCount() throws Exception {
    try (Connection c = DriverManager.getConnection(url(), DB_USER, DB_PASS);
         Statement st = c.createStatement();
         ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM demo_writes")) {
      return rs.next() ? rs.getLong(1) : 0L;
    }
  }

  static void home(HttpExchange e) {
    try {
      long n = rowCount();
      String html = "<html><head><meta charset='utf-8'><title>Movii DR Demo</title></head>"
          + "<body style='font-family:Arial;margin:40px'>"
          + "<h1>Movii — Demo DR (OCI)</h1>"
          + "<p><b>Región que atiende:</b> " + REGION + "</p>"
          + "<p><b>Escrituras en MySQL HeatWave:</b> " + n + "</p>"
          + "<p><a href='/write'>/write</a> para insertar una fila · "
          + "<a href='/count'>/count</a> · <a href='/health'>/health</a></p>"
          + "</body></html>";
      respond(e, 200, html);
    } catch (Exception ex) {
      respond(e, 500, "DB error: " + ex.getMessage());
    }
  }

  static void write(HttpExchange e) {
    try (Connection c = DriverManager.getConnection(url(), DB_USER, DB_PASS);
         Statement st = c.createStatement()) {
      st.executeUpdate("INSERT INTO demo_writes (region) VALUES ('" + REGION + "')");
      respond(e, 200, "inserted from region=" + REGION + " total=" + rowCount());
    } catch (Exception ex) {
      respond(e, 500, "write error: " + ex.getMessage());
    }
  }

  static void count(HttpExchange e) {
    try {
      respond(e, 200, String.valueOf(rowCount()));
    } catch (Exception ex) {
      respond(e, 500, "count error: " + ex.getMessage());
    }
  }

  static void respond(HttpExchange e, int code, String body) {
    try {
      byte[] b = body.getBytes(StandardCharsets.UTF_8);
      e.getResponseHeaders().add("Content-Type", "text/html; charset=utf-8");
      e.sendResponseHeaders(code, b.length);
      try (OutputStream os = e.getResponseBody()) {
        os.write(b);
      }
    } catch (Exception ignored) {
    }
  }
}
