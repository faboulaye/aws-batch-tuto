import reader from "./Reader";
import writer from "./Writer";
import Book from "./Book";

class Batch {
  run(): void {
    let books: Array<Object> = new Array();
    reader
      .read()
      .then(books => books.forEach(book => writer.write(book)));
  }
}

export default new Batch();
