import { DynamoDB } from "aws-sdk";
import Book from "./Book";

class Writer {
  private dynamoDb: DynamoDB;
  
  constructor() {
    this.dynamoDb = new DynamoDB({
      region: "eu-west-1",
      apiVersion: "2012-08-10"
    });
  }
  write(book: Book) {
    console.log(book);
    let params: DynamoDB.PutItemInput = {
      TableName: process.env.BATCH_TABLE as string,
      Item: DynamoDB.Converter.marshall(book)
    };
    this.dynamoDb.putItem(params, function(err, data) {
      if (err) {
        console.log("Error", err);
      } else {
        console.log("Success", data);
      }
    });
  }
}

export default new Writer();
