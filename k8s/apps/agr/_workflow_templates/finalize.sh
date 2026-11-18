# shellcheck shell=sh
generation_id="{{workflow.outputs.parameters.generation-id}}"
cancel_requested="{{workflow.annotations.agr.learning/cancel-requested}}"
workflow_status="{{workflow.status}}"
promote="{{workflow.outputs.parameters.promote}}"
if [ -z "$generation_id" ] || [ "$generation_id" = "{{workflow.outputs.parameters.generation-id}}" ]; then
  exit 0
fi
if [ "$cancel_requested" = "true" ]; then
  outcome=cancelled
else
case "$workflow_status" in
  Succeeded)
    case "$promote" in
      true) outcome=succeeded ;;
      false) outcome=rejected ;;
      *) outcome=succeeded ;;
    esac
    ;;
  Failed|Error) outcome=failed ;;
  *) outcome=cancelled ;;
esac
fi
exec /app/.venv/bin/agr-finalize --generation-id "$generation_id" --workflow-uid "{{workflow.uid}}" --outcome "$outcome"
