# **File Upload Flutter Application**

## **Overview**
This Flutter project allows users to upload large files (videos or documents) to **Supabase Storage** with real-time progress tracking, video preview, error handling, and upload persistence.

---

## **Features**

### 1. File Upload
- Users can upload large files (**minimum size: 100MB**) to Supabase Storage.  
- **Supported file types**: Videos and Documents.  

### 2. Progress Tracking
- Real-time upload progress is displayed using a **progress bar**.  
- Persistent upload notifications are shown, even if the app runs in the background.  

### 3. Video Preview
- Video files display a **thumbnail** before full playback.  
- Includes a play button for video playback.  

### 4. Error Handling
Handles scenarios like:  
- Network interruptions  
- File size constraints  
- Unsupported file types  

Retry option is available for failed uploads.  

### 5. Persistent Upload State
- Uploads **resume automatically** if the app is closed or reopened.

---

## **Tech Stack**
- **Flutter**: Mobile application frontend.  
- **Supabase Storage**: Backend for file storage.  

---

## **Setup Instructions**

### 1. Prerequisites
Ensure you have the following installed:  
- **Flutter SDK**  
- **Supabase account and project created**

---

### 2. Clone the Repository
Clone the project repository:
```bash
git clone [<Repository Url>](https://github.com/AbhinandhanaPU/Media_Upload.git)
cd <project-directory>
```

---

### 3. Setup Supabase

1. Create a Supabase Project at https://supabase.com.


2. Enable Supabase Storage.


3. Obtain your Project URL and API Key from the Supabase dashboard.


4. Add the Supabase configuration to your Flutter project.

---

### 4. Install Dependencies

Run the following command to install required packages:
```bash
flutter pub get
```

Ensure the supabase_flutter package and other dependencies are included in pubspec.yaml:

```yaml
dependencies:
  flutter:
    sdk: flutter
  dotted_border: ^2.1.0
  file_picker: ^8.0.5
  get: ^4.6.6
  fluttertoast: ^8.2.8
  connectivity_plus: ^6.1.1
  supabase_flutter: ^2.8.1
  dio: ^5.7.0
  flutter_local_notifications: ^18.0.1
  video_player: ^2.9.2
  flutter_image_compress: ^2.3.0
  video_thumbnail: ^0.5.3
  path_provider: ^2.1.4
```

---

## **Usage**

File Upload Workflow

1. Select File: Use file_picker to select files from the device.


2. Upload to Supabase Storage

3. Track Progress: Display a progress bar while uploading.


4. Handle Errors: Use try-catch to handle upload failures and allow retries.


5. Preview Videos: Use the video_player package to display a video thumbnail before playback.



---

## **Running the App**

1. Connect a physical device or emulator.


2. Run the app using:
```bash
flutter run
```

---

### Contact

For any questions, please contact Abhinandhana at abhinandhanapu81@gmail.com.
GitHub: Abhinandhana 

---
