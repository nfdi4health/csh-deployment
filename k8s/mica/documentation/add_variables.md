# Add a collected dataset to MICA

1) Login into the system.
   1) Open the given URL in your webbrowser URL:  https://mica.covid19.studyhub.nfdi4health.de/admin
   2) Login with the credentials: username: `administrator` password: ``
   ![login.png](img%2Flogin.png)
2) Select `Individual` and then `Collected Dataset` in the main menu on the top. 
 ![select_collected_datasets_menu.png](img%2Fselect_collected_datasets_menu.png)
3) You will now see the overview of `Collected Dataset`
![collected_dataset_overview.png](img%2Fcollected_dataset_overview.png)
4) Click on the blue `Add Dataset` to add a new dataset to the platform
5) Fill out the form. The properties `Name` and `Acronym` must be the  ID of the object within the 
   German Central Health Study Hub. Also, the property `Link to studyhub` is needed. 
   (The number at the end of the URL is the ID.) 
   Once the information is entered, click `Save`.
   ![collected_dataset_create_init.png](img%2Fcollected_dataset_create_init.png)
6) After creation, you will see the following screen. Click on `Edit`
   ![collected_dataset_created.png](img%2Fcollected_dataset_created.png)
7) Now you can enter the real `Name and `Acronym`, description if provided. 
   ![collected_dataset_edit.png](img%2Fcollected_dataset_edit.png)
8) Once completed you will see the same screen as after the initial creation. 
   Click on the file icon within the left menu. You will see the following screen:
   ![collected_dataset_upload_file.png](img%2Fcollected_dataset_upload_file.png)
   Click on `Upload` and upload the OPAL-formatted Execl file. (Documentation of the format is available)
9) After a sucessfull upload, the following screen will be shown. Click on the `copy` Icon to copy the path of the file.
   You need that path in the next step.
   ![collected_dataset_uploaded_file_copy_path.png](img%2Fcollected_dataset_uploaded_file_copy_path.png)
10) Go back to the overview page by clicking on the eye icon in the left menu. You will see this screen. Click the blue
    `Add Table` button.
    ![collected_dataset_created.png](img%2Fcollected_dataset_created.png)
11) Fill out the form. Select default for `Study`,`Population` and `Data collection event`.
    Select `File source` in the dropdown Data Source. Past the previously copied path of the uploaded file into the path
    field and click `Save`
    ![collected_dataset_edit_study_table.png](img%2Fcollected_dataset_edit_study_table.png)
12) Once saved, you see the familiar screen.
  ![collected_dataset_created.png](img%2Fcollected_dataset_created.png)
13) To publish the collect dataset. Click on `Draft` and then `To under Review`.
   ![collected_dataset_to_review.png](img%2Fcollected_dataset_to_review.png)
14) The screen will refresh and you can click `Publish`. The file will be now processed.
   ![collected_dataset_to_publish.png](img%2Fcollected_dataset_to_publish.png)
15) Either the file can be parsed and the collected dataset will be published or and error will be shown.
    In the first case, the following screen will be shown and you are done.
    ![collected_dataset_published.png](img%2Fcollected_dataset_published.png)
16) If an error occurs the following will be shown and the item is not published. 
    You now need to check the file for errors. You can use the following testcase https://github.com/obiba/magma/blob/master/magma-datasource-excel/src/test/java/org/obiba/magma/datasource/excel/ExcelDatasourceProfile.java
    to debug the error. 
    ![collected_dataset_published_failed.png](img%2Fcollected_dataset_published_failed.png)