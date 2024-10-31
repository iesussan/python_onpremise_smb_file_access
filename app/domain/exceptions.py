class DomainException(Exception):
    """Excepción base para errores de dominio."""
    pass

class FileAccessException(DomainException):
    """Excepción para errores de acceso a archivos."""
    pass

class ConfigurationException(DomainException):
    """Excepción para errores de configuración."""
    pass