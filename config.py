import os

BASE_DIR = os.path.abspath(os.path.dirname(__file__))
# Conexión MySQL - Base de datos estacion_bombeo con tablas en español
SQLALCHEMY_DATABASE_URI = 'mysql+pymysql://root:@localhost:3306/estacion_bombeo?charset=utf8mb4'
# Para SQLite (desarrollo): 'sqlite:///' + os.path.join(BASE_DIR, 'monitoring.db')
# Para PostgreSQL: 'postgresql://usuario:password@localhost/monitoring_db'
SQLALCHEMY_TRACK_MODIFICATIONS = False
SECRET_KEY = 'clave-secreta-para-aplicacion-demo-20240920'
