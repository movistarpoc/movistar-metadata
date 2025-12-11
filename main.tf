#Create a entity hook after creating a new application.
resource "nullplatform_entity_hook_action" "application_create_after" {
   nrn    = var.nrn
   entity = "application"
   action = "application:create"

   dimensions = {}

   when = "after"
   type = "hook"
   on   = "create"
 }

#Create a channel type entity.
resource "nullplatform_notification_channel" "entity-hooks" {
  nrn    = var.nrn
  type   = "agent"
  source = ["entity"]

  configuration {
    agent {
      api_key = var.account_level_np_api_key
      command {
        data = {
          cmdline = "/root/.np/movistarpoc/movistar-metadata/replace_gitlab_values.sh"
          environment = jsonencode({
            NP_ACTION_CONTEXT = "'$${NOTIFICATION_CONTEXT}'"
          })
        }
        type = "exec"
      }
    }
  }
}


#Metadata Namespace Playground
resource "nullplatform_metadata_specification" "metadata_application_playground" {
  name        = "Metadata de Aplicacion Playground"
  description = "Add metadata to application"

  #NRN del namespace Playground 
  nrn         = var.nrn_namespace_playground
  entity      = "application"
  metadata    = "metadata_application_playground"

  schema = jsonencode({
    type = "object"
    properties = {
      "Grupo": {
        "description": "Campo asignado por Namespace",
        "type": "string",
        "default": "Playground",
        "readOnly": true
      },
      "Autor del Proyecto": {
        "description": "Ingresar el mail del autor del proyecto",
        "type": "string",
        "format": "email"
      },
      "Nombre del Agile Team": {
        "description": "Nombre del AGILE TEAM",
        "type": "string",
        "enum": ["Team Playground Alpha", "Team Playground Beta", "Team Playground Gamma", "Team Playground Delta"]
      },
      "Identificador Backend": {
        "description": "Identificador del BACKEND INT",
        "type": "string",
        "enum": ["backend-int-001", "backend-int-002", "backend-int-003", "backend-int-004"]
      },
      "Descripción del Microservicio": {
        "description": "Ingrese una descripcion expresiva del microservicio. Ej: Microservicio que devuelve el offer id de un plan de acuerdo al rol y score entre otros query params",
        "type": "string"
      },
      "Ruta del Microservicio": {
        "description": "Ingrese la ruta que expondra el microservicio. Ej: /get-offer-id/score/:score/role/:role",
        "type": "string",
        "pattern": "^/.*$"
      }
    }
    "required": [
      "Grupo",
      "Autor del Proyecto",
      "Nombre del Agile Team",
      "Identificador Backend",
      "Descripción del Microservicio",
      "Ruta del Microservicio"
    ],
    additionalProperties = false
  })
}


#Metadata Namespace Platform Engineering
resource "nullplatform_metadata_specification" "metadata_application_platform_engineering" {
  name        = "Metadata de Aplicacion API"
  description = "Add metadata to application"

  #NRN del namespace Platform Engineering
  nrn         = var.nrn_namespace_platform_engineering
  entity      = "application"
  metadata    = "metadata_application_platform_engineering"

  schema = jsonencode({
    type = "object"
    properties = {
      "Grupo": {
        "description": "Campo asignado por Namespace",
        "type": "string",
        "default": "API",
        "readOnly": true
      },
      "Autor del Proyecto": {
        "description": "Ingresar el mail del autor del proyecto",
        "type": "string",
        "format": "email"
      },
      "Nombre del Agile Team": {
        "description": "Nombre del AGILE TEAM",
        "type": "string",
        "enum": ["Team API Alpha", "Team API Beta", "Team API Gamma", "Team API Delta"]
      },
      "Identificador Backend": {
        "description": "Identificador del BACKEND INT",
        "type": "string",
        "enum": ["backend-int-001", "backend-int-002", "backend-int-003", "backend-int-004"]
      },
      "Descripción del Microservicio": {
        "description": "Ingrese una descripcion expresiva del microservicio. Ej: Microservicio que devuelve el offer id de un plan de acuerdo al rol y score entre otros query params",
        "type": "string"
      },
      "Ruta del Microservicio": {
        "description": "Ingrese la ruta que expondra el microservicio. Ej: /get-offer-id/score/:score/role/:role",
        "type": "string",
        "pattern": "^/.*$"
      }
    }
    "required": [
      "Grupo",
      "Autor del Proyecto",
      "Nombre del Agile Team",
      "Identificador Backend",
      "Descripción del Microservicio",
      "Ruta del Microservicio"
    ],
    additionalProperties = false
  }) 
}
