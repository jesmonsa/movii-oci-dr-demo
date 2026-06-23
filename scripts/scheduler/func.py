"""
OCI Function (Python) para apagar/encender recursos del demo en horario no hábil.
Filtra por el freeform tag Schedule=office-hours (lo ponen los módulos Terraform).
Dispara con un trigger cron (OCI Resource Scheduler / Events / cron externo).

Body esperado: {"action": "STOP"}  o  {"action": "START"}
Variables de configuración (func.yaml): COMPARTMENT_OCID
"""
import io
import json
import os
import oci
from fdk import response

TAG_KEY = "Schedule"
TAG_VALUE = "office-hours"


def _signer():
    # Usa principal de recurso (resource principal) de la Function.
    return oci.auth.signers.get_resource_principals_signer()


def handle_instances(signer, compartment_id, action):
    compute = oci.core.ComputeClient(config={}, signer=signer)
    search = oci.resource_search.ResourceSearchClient(config={}, signer=signer)
    query = ("query instance resources where freeformTags.key = '%s' "
             "&& freeformTags.value = '%s'" % (TAG_KEY, TAG_VALUE))
    items = search.search_resources(
        oci.resource_search.models.StructuredSearchDetails(
            query=query, type="Structured")).data.items
    done = []
    for it in items:
        if action == "STOP":
            compute.instance_action(it.identifier, "SOFTSTOP")
        else:
            compute.instance_action(it.identifier, "START")
        done.append(it.identifier)
    return done


def handle_mysql(signer, compartment_id, action):
    mysql = oci.mysql.DbSystemClient(config={}, signer=signer)
    systems = oci.pagination.list_call_get_all_results(
        mysql.list_db_systems, compartment_id).data
    done = []
    for s in systems:
        tags = getattr(s, "freeform_tags", {}) or {}
        if tags.get(TAG_KEY) == TAG_VALUE:
            if action == "STOP":
                mysql.stop_db_system(s.id, oci.mysql.models.StopDbSystemDetails(
                    shutdown_type="SLOW"))
            else:
                mysql.start_db_system(s.id)
            done.append(s.id)
    return done


def handler(ctx, data: io.BytesIO = None):
    action = "STOP"
    try:
        body = json.loads(data.getvalue()) if data else {}
        action = (body.get("action") or "STOP").upper()
    except Exception:
        pass
    compartment_id = os.environ.get("COMPARTMENT_OCID", "")
    signer = _signer()
    result = {
        "action": action,
        "instances": handle_instances(signer, compartment_id, action),
        "mysql": handle_mysql(signer, compartment_id, action),
    }
    return response.Response(ctx, response_data=json.dumps(result),
                            headers={"Content-Type": "application/json"})
