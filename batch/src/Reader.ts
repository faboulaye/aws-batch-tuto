import  * as AWS from "aws-sdk";
import csv from "csv-parser";
import fs from "fs";
import Book from "./Book";

class Reader {
  private s3: AWS.S3;
  private file_path: string;

  constructor() {
    this.s3 = new AWS.S3({apiVersion: '2006-03-01'});
    this.file_path = process.env.FILE_PATH as string;
  }

  read(): Promise<Array<Book>> {
    this.loadFile();
    return new Promise((resolve, reject) => {
      let stream = fs.createReadStream(this.file_path).pipe(csv({ separator: ";" }));
      let books: Array<Book> = new Array();
      stream.on("error", err => reject(err));
      stream.on("data", row => books.push(<Book>row));
      stream.on("end", () => resolve(books));
    });
  }

  loadFile() {
    if(process.env.stage === 'CLOUD') {
      this.downloadFromS3();
    }
  }

  downloadFromS3() {
    let params = {
      Bucket: process.env.BUCKET as string,
      Key: process.env.KEY as string
    };
    this.s3.getObject(params, (err, data) => {
      if (err) console.error(err);
      console.log(data);
      //fs.writeFileSync(this.file_path, data.Body.toString());
      console.log(`${this.file_path} has been created!`);
    });
  }
}

export default new Reader();