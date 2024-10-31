import uuid
from smbprotocol.connection import Connection
from smbprotocol.session import Session
from smbprotocol.tree import TreeConnect
from smbprotocol.open import Open, FilePipePrinterAccessMask, ShareAccess, CreateDisposition, CreateOptions, ImpersonationLevel, FileAttributes
# from smbprotocol.create_contexts import (
#     CreateContextName,
#     SMB2CreateContextRequest,
#     SMB2CreateQueryMaximalAccessRequest,
# )
# from smbprotocol.security_descriptor import (
#     AccessAllowedAce,
#     AccessMask,
#     AclPacket,
#     SDControl,
#     SIDPacket,
#     SMB2CreateSDBuffer,
# )
from app.interfaces.smb_repository import ISMBRepository
from app.domain.entities import SMBFilePath, FileData
from app.interfaces.logger_interface import ILogger

class SMBRepository(ISMBRepository):
    def __init__(self, server: str, username: str, password: str, share_name: str, logger: ILogger):
        self.server = server
        self.username = username
        self.password = password
        self.share_name = share_name
        self.logger = logger

    def _connect(self):
        try:
            self.connection = Connection(uuid.uuid4(), self.server)
            self.connection.connect()
            self.session = Session(self.connection, self.username, self.password)
            self.session.connect()
            self.tree = TreeConnect(self.session, f"\\\\{self.server}\\{self.share_name}")
            self.tree.connect()
            self.logger.info(f"Conexión exitosa al servidor SMB: {self.server}")
        except Exception as e:
            self.logger.error(f"Error al conectar al servidor SMB: {e}")
            raise e

    def _disconnect(self):
        self.session.disconnect()
        self.connection.disconnect()

    def read_file(self, file_path: SMBFilePath) -> FileData:
        self._connect()
        try:
            open_file = Open(self.tree, file_path.path)
            open_file.create(
                            ImpersonationLevel.Impersonation,
                            FilePipePrinterAccessMask.GENERIC_READ,
                            FileAttributes.FILE_ATTRIBUTE_NORMAL,
                            ShareAccess.FILE_SHARE_READ,
                            CreateDisposition.FILE_OPEN,
                            CreateOptions.FILE_NON_DIRECTORY_FILE
                            )
            data = open_file.read(0, 1024)
            open_file.close()
            return FileData(content=data)
        finally:
            self._disconnect()