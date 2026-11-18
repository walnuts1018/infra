generation_id="{{workflow.outputs.parameters.generation-id}}"
if [ -z "$generation_id" ] || [ "$generation_id" = "{{workflow.outputs.parameters.generation-id}}" ]; then
  exit 0
fi
if [ "{{workflow.annotations.agr.learning/cancel-requested}}" = "true" ]; then
  outcome=cancelled
else
case "{{workflow.status}}" in
  Succeeded)
    case "{{workflow.outputs.parameters.promote}}" in
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
