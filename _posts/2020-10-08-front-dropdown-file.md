---
layout: post 
title: "[Front] Upload file with Drag and Drop!"
date: 2020-10-14 08:43:59
author: Jamie Lee
categories: Frontend
tags:	Frontend
cover:  "/assets/img/front-end-logo.png"
pagination: 
  enabled: true
---

# drag and drop (front)

# Taking file with more action

 Few days ago, I had to make a function that is about taking excel file from client side and reading it to save to our database. I usually go as simple as possible in terms of HTML/CSS, but this time I did some research and work! Instead of using basic file chose button, dragging a file and dropping in to a box. I was very happy when finishing these process because I thought it's quite user friendly interface.  Go check demo first and let's dig in!

![drag%20and%20drop%20(front)%203bbcb41524264640801dce23e80eb29e/dragdrop.png](/assets/img/post/dragdrop.PNG)

[demo](https://https://leeleelee3264.github.io//demo/dragdrop){: .btn}
 

## HTML

```html
<div class="file-upload">
                <button class="file-upload-btn" type="button" onclick="$('.file-upload-input').trigger( 'click' )">Add Excel</button>

                <div class="image-upload-wrap">
                    <form id="vts_form" enctype="multipart/form-data" method="post">
                        <input class="file-upload-input" name="input-file" type='file' onchange="readURL(this);" accept="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" />
                    </form>
                    <div class="drag-text">
                        <h3>Drag your excel or click<strong> ADD EXCEL</strong></h3>
                    </div>
                </div>
                <div class="file-upload-content">
                    <img class="file-upload-image" src="/assets/img/demo/excelIcon.png" alt="excel icon" />
                    <div class="image-title-wrap">
                        <button type="button" onclick="removeUpload()" class="remove-image">Remove <span class="image-title">Uploaded Excel</span></button>
                        <button type="button"  class="upload-image">Upload <span class="image-title">Uploaded Excel</span></button>
                    </div>
                </div>
            </div>
```

 In file input form, I had to set accept attribute first to let server know what kind of Multipartfile will be uploaded. It called MIME type. I found that MIME type of microsoft file are quite complicated and long. And surprised that there are so many same excel file with hundred extension such as xlsx, xls, cvs! Maybe next time, I need to consider the most general file extension for excel too. 

 And as we all know, our clients make unexpected exception. For example, I made a formatted excel template to write data easily. (giving them select box in cell). But my colleague didn't have excel software and try to open the template in google sheet. Sadly, select box wasn't working. Furthermore, it didn't let us input data manually. It just gave us many alert of 'It's not allowed data in the cell'. The point is, like i said I have to think about more general type of client situation. 

 Anyway here are the extension for microsoft file! You can find normal MIME type such as json, text, audio is here! [MIME type for input tag](https://developer.mozilla.org/ko/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Common_types)

```
Extension MIME Type
.doc      application/msword
.dot      application/msword

.docx     application/vnd.openxmlformats-officedocument.wordprocessingml.document
.dotx     application/vnd.openxmlformats-officedocument.wordprocessingml.template
.docm     application/vnd.ms-word.document.macroEnabled.12
.dotm     application/vnd.ms-word.template.macroEnabled.12

.xls      application/vnd.ms-excel
.xlt      application/vnd.ms-excel
.xla      application/vnd.ms-excel

.xlsx     application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
.xltx     application/vnd.openxmlformats-officedocument.spreadsheetml.template
.xlsm     application/vnd.ms-excel.sheet.macroEnabled.12
.xltm     application/vnd.ms-excel.template.macroEnabled.12
.xlam     application/vnd.ms-excel.addin.macroEnabled.12
.xlsb     application/vnd.ms-excel.sheet.binary.macroEnabled.12

.ppt      application/vnd.ms-powerpoint
.pot      application/vnd.ms-powerpoint
.pps      application/vnd.ms-powerpoint
.ppa      application/vnd.ms-powerpoint

.pptx     application/vnd.openxmlformats-officedocument.presentationml.presentation
.potx     application/vnd.openxmlformats-officedocument.presentationml.template
.ppsx     application/vnd.openxmlformats-officedocument.presentationml.slideshow
.ppam     application/vnd.ms-powerpoint.addin.macroEnabled.12
.pptm     application/vnd.ms-powerpoint.presentation.macroEnabled.12
.potm     application/vnd.ms-powerpoint.template.macroEnabled.12
.ppsm     application/vnd.ms-powerpoint.slideshow.macroEnabled.12

.mdb      application/vnd.ms-access
```

## Javascript

```jsx
function readURL(input) {
        if (input.files && input.files[0]) {

            let reader = new FileReader();

            reader.onload = function (e) {
                document.querySelector('.image-upload-wrap').style.display = 'none';
                document.querySelector('.file-upload-content').style.display = 'block';

                let imgTitles = document.querySelectorAll('.image-title');

                for(let title of imgTitles) {
                    title.innerHTML = input.files[0].name;
                }
            };

            reader.readAsDataURL(input.files[0]);

        } else {
            removeUpload();
        }
    }

    function removeUpload() {
        document.querySelector('.file-upload-input').value = "";
        document.querySelector('.file-upload-content').style.display = 'none';
        document.querySelector('.image-upload-wrap').style.display = 'block';
    }

    document.addEventListener('DOMContentLoaded', function () {
        let imageElement = document.querySelector('.image-upload-wrap');
        let addedClass = 'image-dropping';

        imageElement.addEventListener('dragover', function () {
            imageElement.classList.add(addedClass)
        });

        imageElement.addEventListener('dragleave', function () {
            imageElement.classList.remove(addedClass)
        });
    })
    
```

 Recently I've been trying to use plain javascript only and no jQuery. I was actually surprised that plain javascript cover almost everything. And I struggled a lot with getElementByClassName. It returns collection type, quite different with getElementById. **I found out $('.className') is the same with document.querySelector('.className').** This page is very helpful, [youmightnotneedjquery](http://youmightnotneedjquery.com/)

  When file is uploaded, excel icon will show up. But there was a problem. After removing an uploaded file, I tried to uploading the same file with previous one but the excel icon didn't show up because they are the same one. So I had to add removing img in removeUpload(). It's very simple. Just set file input element to "".

## CSS

  ```css
    *, *:before, *:after {
                box-sizing: border-box;
            }
    
        .file-upload {
            background-color: #ffffff;
            width: 100%;
            margin: 0 auto;
            padding: 20px;
        }

        .file-upload-btn {
            width: 100%;
            margin: 0;
            color: #fff;
            background: dodgerblue;
            border: none;
            padding: 10px;
            border-radius: 4px;
            border-bottom: 4px solid cornflowerblue;
            transition: all .2s ease;
            outline: none;
            text-transform: uppercase;
            font-weight: 700;
        }

        .file-upload-btn:hover {
            background: dodgerblue;
            color: #ffffff;
            transition: all .2s ease;
            cursor: pointer;
        }

        .file-upload-btn:active {
            border: 0;
            transition: all .2s ease;
        }

        .file-upload-content {
            display: none;
            text-align: center;
        }

        .file-upload-input {
            position: absolute;
            margin: 0;
            padding: 0;
            width: 100%;
            height: 100%;
            outline: none;
            opacity: 0;
            cursor: pointer;
        }

        .image-upload-wrap {
            margin-top: 20px;
            border: 4px dashed #1FB264;
            position: relative;
        }

        .image-dropping,
        .image-upload-wrap:hover {
            background-color: gainsboro;
            border: 4px dashed #ffffff;
        }

        .image-title-wrap {
            padding: 0 15px 15px 15px;
            color: #222;
        }

        .drag-text {
            text-align: center;
        }

        .drag-text h3 {
            font-weight: 100;
            text-transform: uppercase;
            color: #15824B;
            padding: 60px 0;
        }

        .file-upload-image {
            max-height: 200px;
            max-width: 200px;
            margin: auto;
            padding: 20px;
        }

        .remove-image {
            width: 200px;
            margin: 0;
            color: #fff;
            background: #cd4535;
            border: none;
            padding: 10px;
            border-radius: 4px;
            border-bottom: 4px solid #b02818;
            transition: all .2s ease;
            outline: none;
            text-transform: uppercase;
            font-weight: 700;
        }

        .remove-image:hover {
            background: grey;
            color: #ffffff;
            transition: all .2s ease;
            cursor: pointer;
        }

        .remove-image:active {
            border: 0;
            transition: all .2s ease;
        }

        .upload-image {
            width: 200px;
            margin: 0;
            color: #fff;
            background: lightseagreen;
            border: none;
            padding: 10px;
            border-radius: 4px;
            border-bottom: 4px solid forestgreen;
            transition: all .2s ease;
            outline: none;
            text-transform: uppercase;
            font-weight: 700;
        }

        .upload-image:hover {
            background: grey;
            color: #ffffff;
            transition: all .2s ease;
            cursor: pointer;
        }

        .upload-image:active {
            border: 0;
            transition: all .2s ease;
        }
  ```
