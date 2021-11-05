# Local testing

If you would like to test the functionality locally, follow the following steps:

1. Install node js via https://nodejs.org/en/ (choose the LTS version)
2. Extract local_testing.zip: https://github.com/mcetn/musicassessr-aws/blob/main/local_testing.zip
3. Change the file directory in the following to where you would like to upload files to locally: 

```
file.mv('/srv/shiny-server/files/' + file.name+".wav");
```

5. cd to the local_testing directory
6. 
```
$ npm install
$ node app.js
```
5. in /inst/static-website-s3/app.js, change:
```
xhr.open("POST","/api/store_audio",true);
```
to
```
xhr.open("POST","http://localhost:3000/upload-audio",true);
```
