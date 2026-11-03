\# Stock Inventory Management App



\## 1. Project Overview



The Stock Inventory Management App is a Flutter-based application developed to manage stock items efficiently. It uses Firebase Cloud Firestore to store and retrieve inventory information. The application allows users to add stock records, search items, filter categories, identify low-stock products, and sort inventory based on quantity.



\## 2. Project Details



\* \*\*Course:\*\* NET4207

\* \*\*Framework:\*\* Flutter

\* \*\*Programming Language:\*\* Dart

\* \*\*Database:\*\* Firebase Cloud Firestore

\* \*\*Firebase Project ID:\*\* net4207-stock-inventory-bb5c5

\* \*\*Firestore Collection:\*\* stockItems



\## 3. Technologies Used



\* Flutter

\* Dart

\* Firebase Cloud Firestore

\* Firebase Core

\* Cloud Firestore Flutter Package

\* Android Studio

\* Git and GitHub



\## 4. Main Features



1\. Add new stock items using an entry form.

2\. Validate all required fields before saving.

3\. Store stock information in Firebase Firestore.

4\. Retrieve and display saved inventory records.

5\. Search items by name or SKU.

6\. Filter items by category.

7\. Identify low-stock items.

8\. Sort inventory by quantity in ascending or descending order.

9\. Clear filters to display all inventory records.



\## 5. Firestore Database Structure



Collection name: `stockItems`



Each document contains the following fields:



| Field        | Data Type | Description                 |

| ------------ | --------- | --------------------------- |

| sku          | String    | Stock identification number |

| itemName     | String    | Name of the item            |

| category     | String    | Item category               |

| quantity     | Integer   | Available stock quantity    |

| unitPrice    | Number    | Price per unit              |

| reorderLevel | Integer   | Minimum stock level         |

| createdAt    | Timestamp | Record creation time        |



\## 6. Form Validation



The application includes validation to ensure that users enter correct information.



\* All six input fields are required.

\* SKU must follow the format STK- followed by three digits.

\* Item name must contain at least three characters.

\* Category must be selected.

\* Quantity must be a non-negative integer.

\* Unit price must be greater than zero.

\* Reorder level must be a non-negative integer.

\* The form is validated before saving data to Firebase.



\## 7. Advanced Search and Filtering



The application provides advanced search and filtering functionality.



\* Search by item name or SKU.

\* Search is case-insensitive and supports partial matches.

\* Filter inventory by category.

\* Identify low-stock items when quantity is less than or equal to reorder level.

\* Combine search, category, and low-stock filters.

\* Sort inventory by quantity in ascending or descending order.

\* Clear all filters to display the complete inventory.



\## 8. Installation and Execution



\### Requirements



\* Flutter SDK

\* Dart SDK

\* Android Studio or Visual Studio Code

\* Firebase configuration



\### Commands to run the application



Open the project terminal and execute:



```bash

flutter pub get

```



Then run the application in Chrome:



```bash

flutter run -d chrome

```



\## 9. Firebase Configuration



The application is connected to Firebase Cloud Firestore.



Firebase Project ID:



`net4207-stock-inventory-bb5c5`



The Firebase configuration is stored in:



`lib/firebase\_options.dart`



The application uses the `stockItems` collection to save and retrieve stock information.



Do not upload private keys, passwords, or Firebase service-account credentials to GitHub.



\## 10. Sample Test Data



Use the following records to test the application.



| SKU     | Item Name      | Category    | Quantity | Unit Price (RM) | Reorder Level |

| ------- | -------------- | ----------- | -------: | --------------: | ------------: |

| STK-101 | USB C Cable    | Electronics |        4 |           19.90 |             5 |

| STK-102 | Notebook       | Stationery  |       25 |            4.50 |            10 |

| STK-103 | Wireless Mouse | Electronics |        1 |           35.00 |             3 |



\## 11. Testing and Results



| Test Case                              | Expected Result                                              | Status                       |

| -------------------------------------- | ------------------------------------------------------------ | ---------------------------- |

| Submit an empty or invalid form        | Validation errors should appear and data should not be saved | Pending verification         |

| Save valid stock records               | Records should be stored in Firebase Firestore               | Verified for a sample record |

| Retrieve saved records                 | Saved inventory should appear after reloading                | Verify all three records     |

| Search mouse + Electronics + Low Stock | Only STK-103 Wireless Mouse should appear                    | Pending verification         |

| Sort by quantity ascending             | STK-103, STK-101, STK-102                                    | Pending verification         |

| Clear filters                          | All saved inventory records should appear                    | Pending verification         |



\*\*Note:\*\* Update the test statuses after completing each test. Do not mark untested features as verified.



\## 12. Screenshots and Evidence



Create a folder named `screenshots` in the project directory.



Add screenshots showing:



1\. Application home screen.

2\. Stock entry form.

3\. Form validation errors.

4\. Firebase Firestore records.

5\. Inventory list.

6\. Advanced search and filtering.

7\. Quantity sorting results.



These screenshots provide evidence of the application's functionality.



\## 13. GitHub Submission



The project repository should contain:



\* Flutter source code.

\* README.md.

\* pubspec.yaml.

\* Android and Web project files.

\* Screenshots folder.



Do not upload passwords, private keys, or sensitive Firebase credentials.



\## 14. Conclusion



The Stock Inventory Management App demonstrates how Flutter and Firebase Cloud Firestore can be used to develop a stock management system. It provides stock entry, form validation, cloud database integration, inventory retrieval, advanced search, filtering, and sorting features. The application helps users manage inventory information efficiently.



