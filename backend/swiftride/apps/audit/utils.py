from .models import AuditLog


def log_action(actor, action, entity_type, entity_id, description, meta=None, ip=None, ua=''):
    AuditLog.objects.create(
        actor       = actor,
        action      = action,
        entity_type = entity_type,
        entity_id   = str(entity_id),
        description = description,
        meta        = meta or {},
        ip_address  = ip,
        user_agent  = ua,
    )
