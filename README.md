# SMB File Access Project

Este proyecto es una aplicación Python que permite acceder a archivos en un recurso compartido SMB remoto (onpremise o azure tipo IaaS). Utiliza la biblioteca `smbprotocol` para manejar la conexión y lectura de archivos desde el servidor SMB.

## Estructura del Proyecto
```bash
├── Dockerfile
├── IaC
│   ├── webapp_for_container.sh
│   └── windows_vm.sh
├── README.md
├── app
│   ├── domain
│   │   ├── __init__.py
│   │   ├── entities.py
│   │   └── exceptions.py
│   ├── infrastructure
│   │   ├── __init__.py
│   │   ├── config.py
│   │   ├── logger_impl.py
│   │   └── smb_repository_impl.py
│   ├── interfaces
│   │   ├── __init__.py
│   │   ├── logger_interface.py
│   │   └── smb_repository.py
│   └── use_cases
│       ├── __init__.py
│       └── access_shared_folder.py
├── main.py
└── requirements.txt
```
## Requisitos

- Python 3.9
- `pip` (Python package installer)
- Docker (opcional, para despliegue en contenedores)

## Crea un entorno virtual y actívalo:
```bash
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## Configuración
Configura las siguientes variables de entorno antes de ejecutar la aplicación:

* SMB_SERVER: Dirección del servidor SMB.
* SMB_USERNAME: Nombre de usuario para autenticarse en el servidor SMB.
* SMB_PASSWORD: Contraseña para autenticarse en el servidor SMB.
* SMB_SHARE: Nombre del recurso compartido en el servidor SMB.
* SMB_FILE_PATH: Ruta del archivo dentro del recurso compartido SMB.

## Ejecución

Para ejecutar la aplicación, usa el siguiente comando:
```bash
docker build -t smb_access_project .
```

## Estructura del Código
* **main.py:** Punto de entrada de la aplicación.
* **app/domain/:** Contiene las entidades y excepciones del dominio.
* **app/infrastructure/:** Implementaciones de infraestructura, incluyendo configuración, logger y repositorio SMB.
* **app/interfaces/:** Interfaces para el logger y el repositorio SMB.
* **app/use_cases/:** Casos de uso de la aplicación.
* **IaC/:** Scripts de infraestructura como código para desplegar la aplicación en Azure.

## Contribuciones
Las contribuciones son bienvenidas. Por favor, abre un issue o un pull request para discutir cualquier cambio que te gustaría hacer.