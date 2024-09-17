import os
import subprocess
import argparse
import uuid


def main():
    parser = argparse.ArgumentParser(
        prog='task',
        description='var: 367974')

    parser.add_argument("-f", "--filename", required=True)
    parser.add_argument("-u", "--username", required=True)
    parser.add_argument("-p", "--password", required=True)
    parser.add_argument("-s", "--schema", required=True)
    parser.add_argument("-s", "--database", required=True)

    args = parser.parse_args()

    tempfile_filename = str(uuid.uuid4())

    if args.filename:
        file = open(args.filename, "r")
        content = file.read()
        file.close()
        content = content.replace('public', args.schema)
        tmp_file = open(f"/tmp/{tempfile_filename}.sql", "a")
        print(f"/tmp/{tempfile_filename}.sql")
        tmp_file.write(content)
        tmp_file.close()

    if args.password or os.environ["PGPASSWORD"]:
        if args.password:
            os.environ["PGPASSWORD"] = args.password
        output = subprocess.run(["psql", "-h", "localhost", "-p", "5432", "-U",
                                 args.username, "-d", args.database, "-f", f"/tmp/{tempfile_filename}.sql"])
        print(output.returncode)


if __name__ == "__main__":
    main()
