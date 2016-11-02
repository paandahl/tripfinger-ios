export default class FileSystem {
  static _file;

  static storage = {};

  static async readFile() {
    return FileSystem._file;
  }

  static async fileExists() {
    return false;
  }

  // noinspection Eslint
  static async delete() {}
}
