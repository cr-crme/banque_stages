# This script resets the database by executing a SQL file within a Docker container.

import os
import sys
import subprocess
import uuid


_database = "dev_db"
_base_docker_command = "docker exec -i banque_stage_container mysql -u devuser -pdevpassword".split()


def main(super_admin_email: str):
    # Get the path to the SQL file
    sql_filename = "reset_database.sql"
    sql_file_path = os.path.join(os.path.dirname(__file__), sql_filename)

    # Check if the SQL file exists
    if not os.path.exists(sql_file_path):
        print(f"SQL reset file ({sql_filename}) not found: {sql_file_path}")
        sys.exit(1)

    # Reset the database
    if not reset_database(sql_file_path):
        print("Failed to reset the database.")
        return
    print("Database reset successfully.")

    # Add an admin user
    if not add_super_admin_user(super_admin_email=super_admin_email):
        print("Failed to add admin user.")
        return
    print("Admin user added successfully.")


def reset_database(sql_filepath: str) -> bool:
    # Run the command to reset the database
    # docker exec -i banque_stage_container mysql -u devuser -pdevpassword < reset_database.sql
    with open(sql_filepath, "rb") as sql_file:
        result = subprocess.run(_base_docker_command, stdin=sql_file, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    # Check if the command was successful
    if result.returncode == 0:
        return True
    else:
        print(result.stderr.decode())
        return False


def add_super_admin_user(super_admin_email: str) -> bool:
    # Use uuid v4 to generate a random ID
    id = str(uuid.uuid4())

    query = f"""
    INSERT INTO entities (shared_id) 
    VALUES ('{id}');
    """
    if not _perform_query(query):
        return False

    query = f"""
    INSERT INTO admins (id, school_board_id, first_name, last_name, email, access_level) 
    VALUES ('{id}', '', 'Super', 'Admin', '{super_admin_email}', 3);
    """
    if not _perform_query(query):
        return False

    return True


def _perform_query(query: str) -> bool:
    # Run the query against the database
    result = subprocess.run(
        _base_docker_command + [_database, "-e", query], stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )
    if result.returncode != 0:
        print(f"Error executing query: {result.stderr.decode()}")
        return False
    return True


if __name__ == "__main__":
    # Get the super admin email from BANQUE_STAGE_SUPERADMIN_EMAIL environment variable
    super_admin_email = os.getenv("BANQUE_STAGE_SUPERADMIN_EMAIL")
    if not super_admin_email:
        print("Environment variable BANQUE_STAGE_SUPERADMIN_EMAIL is not set.")
        sys.exit(1)

    main(super_admin_email=super_admin_email)
