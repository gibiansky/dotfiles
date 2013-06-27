
try:
    import settings
    import django.core.management
    django.core.management.setup_environ(settings)
except ImportError:
    pass

