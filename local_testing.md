If you would like to test the functionality locally, follow the following steps:

1. Install node js via https://nodejs.org/en/ (choose the LTS version)
2. Extract local_testing.zip: https://github.com/mcetn/musicassessr-aws/blob/main/local_testing.zip
3. cd to the files-upload  
4. 
```
$ npm install
$ npm start
```
5. in /inst/static-website-s3/app.js, change this xhr.open("POST","/api/store_audio",true);
 to 	xhr.open("POST","http://localhost:3000/api/store_audio",true);
