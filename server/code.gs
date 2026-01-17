/**
 * Google Apps Script for PDF Conversion
 * 
 * Instructions:
 * 1. Create a new Google Apps Script project at https://script.google.com/
 * 2. Paste this code into 'Code.gs'.
 * 3. Click 'Deploy' -> 'New deployment'.
 * 4. Select type: 'Web app'.
 * 5. Configuration:
 *    - Description: "PDF Converter"
 *    - Execute as: "Me"
 *    - Who has access: "Anyone" (Required for the app to access it without OAuth flow)
 * 6. Copy the "Web App URL" and paste it into the App Settings.
 */

function doPost(e) {
  try {
    const data = JSON.parse(e.postData.contents);
    const action = data.action;
    const inputBase64 = data.file;
    const fileName = data.filename || "document";
    
    if (action === "convert") {
      return convertToPdf(inputBase64, fileName);
    } else {
      return errorResponse("Unknown Data action: " + action);
    }
  } catch (error) {
    return errorResponse(error.toString());
  }
}

function convertToPdf(base64, filename) {
  // 1. Create a temporary blob from the input
  const blob = Utilities.newBlob(Utilities.base64Decode(base64), MimeType.MICROSOFT_WORD, filename);
  
  // 2. Save the file to Drive (temporarily)
  // Note: 'Drive' service must be enabled in 'Services' on the left sidebar in Apps Script editor.
  // Use DriveApp as a fallback if Drive API is not enabled, but Drive.Files.insert is better for conversion.
  
  // We'll use the robust Drive API (Advanced Service).
  // If user hasn't enabled it, we fallback to DriveApp which is trickier for conversion.
  // STRATEGY: Create file -> Get ID -> Get as PDF -> Delete File.
  
  const resource = {
    title: filename,
    mimeType: MimeType.GOOGLE_DOCS
  };
  
  // Using DriveApp (Simpler for users, no Advanced Service setup needed generally, 
  // but DriveApp doesn't auto-convert Word to GDoc on upload easily without Drive API).
  // Let's assume we implement the 'Drive API' enabled version for robustness.
  
  // For simplicity guide: We will require the user to enable "Drive API" in Services.
  let fileId;
  try {
     const savedFile = Drive.Files.insert(resource, blob, {convert: true});
     fileId = savedFile.id;
  } catch (e) {
    return errorResponse("Drive API error. Please enable 'Drive API' in Apps Script Services. " + e.toString());
  }
  
  // 3. Export the file as PDF
  const pdfBlob = DriveApp.getFileById(fileId).getAs(MimeType.PDF);
  const pdfBase64 = Utilities.base64Encode(pdfBlob.getBytes());
  
  // 4. Cleanup
  DriveApp.getFileById(fileId).setTrashed(true);
  
  return successResponse({
    file: pdfBase64,
    filename: filename + ".pdf"
  });
}

function successResponse(data) {
  return ContentService.createTextOutput(JSON.stringify({
    status: "success",
    data: data
  })).setMimeType(ContentService.MimeType.JSON);
}

function errorResponse(message) {
  return ContentService.createTextOutput(JSON.stringify({
    status: "error",
    message: message
  })).setMimeType(ContentService.MimeType.JSON);
}
