# Makefile for compiling mydartproject with Dart

# Project name (output executable)
TARGET = stagess_backend
API_KEY_FILE = backendFirebaseServiceAccountKey.json

# Main Dart file
MAIN = bin/backend.dart

# Dart compiler
DART = dart

# Build directory
BUILD_DIR = build

# Service file for systemd
INSTALL_DIR = ~/services/$(TARGET)
LAUNCHER_FILE_NAME = $(TARGET).sh
LOG_FILE = stagess_backend.log
SERVICE_FILE_NAME = $(TARGET).service
SERVICE_FILE_PATH = /etc/systemd/system/$(SERVICE_FILE_NAME)

# Default target
all: compile launcher service

# Compile Dart to native executable
compile:
	mkdir -p $(BUILD_DIR)
	cp $(API_KEY_FILE) ${BUILD_DIR}/
	$(DART) compile exe $(MAIN) -o $(BUILD_DIR)/$(TARGET)

launcher:
	mkdir -p $(BUILD_DIR)
	echo "#!/bin/bash" | tee ${BUILD_DIR}/$(LAUNCHER_FILE_NAME)
	echo "" | tee -a ${BUILD_DIR}/$(LAUNCHER_FILE_NAME)
	echo "# Define the required exports" | tee -a ${BUILD_DIR}/$(LAUNCHER_FILE_NAME)
	echo "export STAGESS_SQL_COMMAND=${STAGESS_SQL_COMMAND}" | tee -a ${BUILD_DIR}/$(LAUNCHER_FILE_NAME)
	echo "export STAGESS_USE_SSL=${STAGESS_USE_SSL}" | tee -a ${BUILD_DIR}/$(LAUNCHER_FILE_NAME)
	echo "export STAGESS_CERT_PEM=${STAGESS_CERT_PEM}" | tee -a ${BUILD_DIR}/$(LAUNCHER_FILE_NAME)
	echo "export STAGESS_KEY_PEM=${STAGESS_KEY_PEM}" | tee -a ${BUILD_DIR}/$(LAUNCHER_FILE_NAME)
	echo "export STAGESS_FIREBASE_WEB_API_KEY=${STAGESS_FIREBASE_WEB_API_KEY}" | tee -a ${BUILD_DIR}/$(LAUNCHER_FILE_NAME)
	echo "export STAGESS_USE_LOCAL_DATABASE=${STAGESS_USE_LOCAL_DATABASE}" | tee -a ${BUILD_DIR}/$(LAUNCHER_FILE_NAME)
	echo "export STAGESS_SUPERADMIN_EMAIL=${STAGESS_SUPERADMIN_EMAIL}" | tee -a ${BUILD_DIR}/$(LAUNCHER_FILE_NAME)
	echo "export STAGESS_DATABASE_BACKEND=${STAGESS_DATABASE_BACKEND}" | tee -a ${BUILD_DIR}/$(LAUNCHER_FILE_NAME)
	echo "export STAGESS_DATABASE_DEV_PORT=${STAGESS_DATABASE_DEV_PORT}" | tee -a ${BUILD_DIR}/$(LAUNCHER_FILE_NAME)
	echo "export STAGESS_DATABASE_DEV_NAME=${STAGESS_DATABASE_DEV_NAME}" | tee -a ${BUILD_DIR}/$(LAUNCHER_FILE_NAME)
	echo "export STAGESS_DATABASE_DEV_USER=${STAGESS_DATABASE_DEV_USER}" | tee -a ${BUILD_DIR}/$(LAUNCHER_FILE_NAME)
	echo "export STAGESS_DATABASE_DEV_PASSWORD=${STAGESS_DATABASE_DEV_PASSWORD}" | tee -a ${BUILD_DIR}/$(LAUNCHER_FILE_NAME)
	echo "export STAGESS_DATABASE_PRODUCTION_PORT=${STAGESS_DATABASE_PRODUCTION_PORT}" | tee -a ${BUILD_DIR}/$(LAUNCHER_FILE_NAME)
	echo "export STAGESS_DATABASE_PRODUCTION_NAME=${STAGESS_DATABASE_PRODUCTION_NAME}" | tee -a ${BUILD_DIR}/$(LAUNCHER_FILE_NAME)
	echo "export STAGESS_DATABASE_PRODUCTION_USER=${STAGESS_DATABASE_PRODUCTION_USER}" | tee -a ${BUILD_DIR}/$(LAUNCHER_FILE_NAME)
	echo "export STAGESS_DATABASE_PRODUCTION_PASSWORD=${STAGESS_DATABASE_PRODUCTION_PASSWORD}" | tee -a ${BUILD_DIR}/$(LAUNCHER_FILE_NAME)
	echo "" | tee -a ${BUILD_DIR}/$(LAUNCHER_FILE_NAME)
	echo "# Define the log file name" | tee -a ${BUILD_DIR}/$(LAUNCHER_FILE_NAME)
	echo "LOG_FILE=$(LOG_FILE)" | tee -a ${BUILD_DIR}/$(LAUNCHER_FILE_NAME)
	echo "" | tee -a ${BUILD_DIR}/$(LAUNCHER_FILE_NAME)
	echo "# Run the backend" | tee -a ${BUILD_DIR}/$(LAUNCHER_FILE_NAME)
	echo "./$(TARGET) > $(LOG_FILE) 2>&1" | tee -a ${BUILD_DIR}/$(LAUNCHER_FILE_NAME)
	chmod +x ${BUILD_DIR}/$(LAUNCHER_FILE_NAME)

service:
	mkdir -p $(BUILD_DIR)
	echo "[Unit]" | tee ${BUILD_DIR}/$(SERVICE_FILE_NAME)
	echo "Description=$(TARGET) Dart Service" | tee -a ${BUILD_DIR}/$(SERVICE_FILE_NAME)
	echo "After=network.target" | tee -a ${BUILD_DIR}/$(SERVICE_FILE_NAME)
	echo "" | tee -a ${BUILD_DIR}/$(SERVICE_FILE_NAME)
	echo "[Service]" | tee -a ${BUILD_DIR}/$(SERVICE_FILE_NAME)
	echo "ExecStart=$(INSTALL_DIR)/$(TARGET)" | tee -a ${BUILD_DIR}/$(SERVICE_FILE_NAME)
	echo "WorkingDirectory=$(INSTALL_DIR)" | tee -a ${BUILD_DIR}/$(SERVICE_FILE_NAME)
	echo "Restart=always" | tee -a ${BUILD_DIR}/$(SERVICE_FILE_NAME)
	echo "RestartSec=5" | tee -a ${BUILD_DIR}/$(SERVICE_FILE_NAME)
	echo "User=www-data" | tee -a ${BUILD_DIR}/$(SERVICE_FILE_NAME)
	echo "Environment=STAGESS_FIREBASE_WEB_API_KEY="${STAGESS_FIREBASE_WEB_API_KEY}"" | tee -a ${BUILD_DIR}/$(SERVICE_FILE_NAME)
	echo "Environment=STAGESS_USE_SSL="${STAGESS_USE_SSL}"" | tee -a ${BUILD_DIR}/$(SERVICE_FILE_NAME)
	echo "Environment=STAGESS_CERT_PEM="${STAGESS_CERT_PEM}"" | tee -a ${BUILD_DIR}/$(SERVICE_FILE_NAME)
	echo "Environment=STAGESS_KEY_PEM="${STAGESS_KEY_PEM}"" | tee -a ${BUILD_DIR}/$(SERVICE_FILE_NAME)
	echo "Environment=STAGESS_USE_LOCAL_DATABASE="${STAGESS_USE_LOCAL_DATABASE}"" | tee -a ${BUILD_DIR}/$(SERVICE_FILE_NAME)
	echo "Environment=STAGESS_DATABASE_BACKEND="${STAGESS_DATABASE_BACKEND}"" | tee -a ${BUILD_DIR}/$(SERVICE_FILE_NAME)
	echo "Environment=STAGESS_DATABASE_DEV_PORT="${STAGESS_DATABASE_DEV_PORT}"" | tee -a ${BUILD_DIR}/$(SERVICE_FILE_NAME)
	echo "Environment=STAGESS_DATABASE_DEV_NAME="${STAGESS_DATABASE_DEV_NAME}"" | tee -a ${BUILD_DIR}/$(SERVICE_FILE_NAME)
	echo "Environment=STAGESS_DATABASE_DEV_USER="${STAGESS_DATABASE_DEV_USER}"" | tee -a ${BUILD_DIR}/$(SERVICE_FILE_NAME)
	echo "Environment=STAGESS_DATABASE_DEV_PASSWORD="${STAGESS_DATABASE_DEV_PASSWORD}"" | tee -a ${BUILD_DIR}/$(SERVICE_FILE_NAME)
	echo "Environment=STAGESS_DATABASE_PRODUCTION_PORT="${STAGESS_DATABASE_PRODUCTION_PORT}"" | tee -a ${BUILD_DIR}/$(SERVICE_FILE_NAME)
	echo "Environment=STAGESS_DATABASE_PRODUCTION_NAME="${STAGESS_DATABASE_PRODUCTION_NAME}"" | tee -a ${BUILD_DIR}/$(SERVICE_FILE_NAME)
	echo "Environment=STAGESS_DATABASE_PRODUCTION_USER="${STAGESS_DATABASE_PRODUCTION_USER}"" | tee -a ${BUILD_DIR}/$(SERVICE_FILE_NAME)
	echo "Environment=STAGESS_DATABASE_PRODUCTION_PASSWORD="${STAGESS_DATABASE_PRODUCTION_PASSWORD}"" | tee -a ${BUILD_DIR}/$(SERVICE_FILE_NAME)
	echo "" | tee -a ${BUILD_DIR}/$(SERVICE_FILE_NAME)
	echo "[Install]" | tee -a ${BUILD_DIR}/$(SERVICE_FILE_NAME)
	echo "WantedBy=multi-user.target" | tee -a ${BUILD_DIR}/$(SERVICE_FILE_NAME)

# Clean build files
clean:
	rm -rf $(BUILD_DIR)

install: all
	mkdir -p $(INSTALL_DIR)
	cp $(BUILD_DIR)/$(TARGET) $(INSTALL_DIR)/
	cp $(BUILD_DIR)/$(API_KEY_FILE) $(INSTALL_DIR)/
	cp $(BUILD_DIR)/$(LAUNCHER_FILE_NAME) $(INSTALL_DIR)/

deploy: install
	sudo cp $(BUILD_DIR)/$(SERVICE_FILE_NAME) $(SERVICE_FILE_PATH)
	sudo systemctl daemon-reload
	sudo systemctl enable $(TARGET)
	sudo systemctl start $(TARGET)

# Phony targets (not files)
.PHONY: all run clean
