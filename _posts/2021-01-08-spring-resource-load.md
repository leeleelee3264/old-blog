---
layout: post 
title: "[Spring] Loading resource inside of jar and outside of jar"
date: 2021-01-08 22:00:00
author: Jamie Lee
categories: Backend
tags:	SpringBoot
pagination: 
  enabled: true
---

Roughly 4 months age, I was assigned to make function with excel. It was like this. I had made a template excel in advance and my colleagues downloaded it and filled it. After that, I read it and inserted data to database. 
And this week, I was assigned new function also related with excel. I have to make a excel file which is analysis purpose and let it get downloaded. Sadly, data in the excel file get changed frequently, so I cannot cached the file for later. 
This function has to make excel every request. Both are about downloading excel file in server. But there is a huge difference. 

## First case 
- static file.
- I have to make and save file before deploying. (making jar file)
- Never got changed, because it's a template! 
- Can saved in jar static dir (inside of jar)

## Second case 
- dynamic file. 
- I have to make and save file on run time. 
- Always freshly made!
- jar already closed, can saved in other dir (outside of jar)

> With Spring resource loder, location of file matter! 

In short, 
1. Use ClassPathResource and relative path to get file in jar
2. Use ResourceLoader and absolute path to get file outside of jar

I checked answer here! [Classpath resource not found when running as jar](https://stackoverflow.com/questions/25869428/classpath-resource-not-found-when-running-as-jar)

```java
    
    private final MediaType excelType = MediaType.parseMediaType("application/vnd.ms-excel");

    // First case controller 
     String EXCEL_STATIC_PATH = "static/excel/"
    
     @GetMapping("/{data}/template/download")
        @ResponseBody
        public ResponseEntity<Resource> getTemplate(
                @PathVariable(name = "data") String data
        ) {
            String requestData = Util.nvl(data);
            String fileName = "";
    
            if (requestData.equals("vts")) {
                fileName = "vts_template.xlsx"; 
            }
    
            try {
                ClassPathResource classPathResource = new ClassPathResource(EXCEL_STATIC_PATH + fileName);
    
                return ResponseEntity.ok()
                        .header(HttpHeaders.CONTENT_DISPOSITION, "attachment;filename=" + classPathResource.getFilename())
                        .header(HttpHeaders.CONTENT_LENGTH, String.valueOf(classPathResource.contentLength()))
                        .header(HttpHeaders.CONTENT_TYPE, String.valueOf(excelType))
                        .body(classPathResource);
            } catch (Exception e) {
                log.error(e.getMessage(), e);
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
            }
        }

     // Second case controller 
      
      @Autowired
      private ResourceLoader resourceLoader;
      
      @Value("${property.excel.dir}")
      private String EXCEL_GENERATED_DIR; 

      @GetMapping(value = "/{type}/count/download")
        @ResponseBody
        public ResponseEntity<Resource> testGetValueFromExcel(
                @PathVariable(name = "type") String type
        ) {
    
            String ttsType = validDnxTts.get(type);
            log.info("CHECK PATH: {}", EXCEL_GENERATED_DIR);
            String fileName = excelService.makeVtsMessageExcel(ttsType, type, EXCEL_GENERATED_DIR);
            Resource resultResource;
    
            try {
                // This name will be showed up to client
                String fullFile = new StringBuilder().append(EXCEL_SEVER_HOST).append("_").append(fileName).toString();
    
                 resultResource = resourceLoader.getResource("file:" + EXCEL_GENERATED_DIR + fileName);
    
                return ResponseEntity.ok()
                        .header(HttpHeaders.CONTENT_DISPOSITION, "attachment;filename=" + fullFile)
                        .header(HttpHeaders.CONTENT_LENGTH, String.valueOf(resultResource.contentLength()))
                        .header(HttpHeaders.CONTENT_TYPE, String.valueOf(excelType))
                        .body(resultResource);
            } catch (Exception e) {
                log.error(e.getMessage(), e);
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
            }
        }
```

### Minor fun fact 
1. File storage path grammar is different, so had better write down both on properties file. 
```yaml
# application.properties --> for local (windows) 
property.excel.dir=\\C:\\Temp\\Admin\\
# application-prod.properties --> for dev (linux)
property.excel.dir=/opt/temp/
```
2. Accidently attach '/' in  resourceLoader.getResource("file:" + EXCEL_GENERATED_DIR + fileName);
So in Linux, it looks like file://opt/temp/. Just like any other url http://something or ftp://something. 
In this case, I saw java.net.UnknownHostException: socialweb-analytics.lcloud.com: Name or service not known exception lol. 
Server thinks it's host. Usually people solve this problem adding new host in /etc/hosts. For example,

```bash
127.0.0.1 localhost
172.168.1.1 file_server 
```


