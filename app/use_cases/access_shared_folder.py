from concurrent.futures import ThreadPoolExecutor
from app.domain.entities import SMBFilePath, FileData
from app.interfaces.smb_repository import ISMBRepository
from app.interfaces.logger_interface import ILogger

class AccessSharedFolderUseCase:
    def __init__(self, smb_repository: ISMBRepository, logger: ILogger):
        self.smb_repository = smb_repository
        self.logger = logger
        self.executor = ThreadPoolExecutor()

    def execute(self, file_path: SMBFilePath):
        try:
            self.logger.info(f"Accediendo al archivo: {file_path.path}")
            data = self.executor.submit(self.smb_repository.read_file, file_path).result()
            self.logger.info("Lectura exitosa del archivo.")
            # Aquí puedes agregar lógica adicional de procesamiento
            return data
        except Exception as e:
            self.logger.error(f"Error al acceder al archivo: {e}")
            raise