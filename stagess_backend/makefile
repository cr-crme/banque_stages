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
INSTALL_DIR = /opt/$(TARGET)
SERVICE_FILE_NAME = $(TARGET).service
SERVICE_FILE = /etc/systemd/system/$(SERVICE_FILE_NAME)


# Default target
all: compile service

# Compile Dart to native executable
compile:
	mkdir -p $(BUILD_DIR)
	$(DART) compile exe $(MAIN) -o $(BUILD_DIR)/$(TARGET)

service:
	mkdir -p $(BUILD_DIR)
	cp $(API_KEY_FILE) ${BUILD_DIR}/
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

deploy: all
	mkdir -p $(INSTALL_DIR)
	cp $(BUILD_DIR)/$(TARGET) $(INSTALL_DIR)/
	cp $(BUILD_DIR)/$(API_KEY_FILE) $(INSTALL_DIR)/
	cp $(BUILD_DIR)/$(SERVICE_FILE_NAME) $(SERVICE_FILE)
	sudo systemctl daemon-reload
	sudo systemctl enable $(TARGET)
	sudo systemctl start $(TARGET)

# Phony targets (not files)
.PHONY: all run clean
