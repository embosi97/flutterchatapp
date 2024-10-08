import 'package:flutter/material.dart'; //Importing basic Flutter components
import 'package:firebase_auth/firebase_auth.dart'; //Importing Firebase Authentication for user auth
import 'package:image_picker/image_picker.dart'; //Importing Image Picker
import 'dart:io'; //For File
import 'chat_screen.dart'; //The chat screen to navigate to after login

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Authentication instance
  final GlobalKey<FormState> _formKey = GlobalKey(); // Key for the form validation
  String _email = ''; //Store the email entered by the user
  String _password = ''; //Store the password entered by the user
  String _errorMessage = ''; //Store any error messages
  File? _image; //Store the selected image file

  //Function to handle login
  Future<void> _login() async {
    final isValid = _formKey.currentState?.validate(); // Validates the form
    if (!isValid!) return; //If the form isn't valid, return

    _formKey.currentState?.save(); //Save form input values

    try {
      //This will try to sign in with email and password
      await _auth.signInWithEmailAndPassword(email: _email, password: _password);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ChatScreen())); // Navigate to chat screen on successful login
    } catch (error) {
      //Handle login errors by displaying an error message
      setState(() {
        _errorMessage = error.toString();
      });
    }
  }

  //Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File("assets/mickeymouse.png"); //Set the selected image file
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'), //Title of the login screen
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), //Padding for the form
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage, //Allow user to pick an image by tapping
              child: CircleAvatar(
                radius: 50, //Avatar size
                backgroundImage: _image != null ? FileImage(_image!) : null, //Display the picked image if available
                child: _image == null ? const Icon(Icons.camera_alt, size: 50) : null, //Show camera icon if no image is picked
              ),
            ),
            const SizedBox(height: 20), //Spacing
            Form(
              key: _formKey, //Form key
              child: Column(
                children: [
                  //Email Input Field
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'), //Label for the email input field
                    keyboardType: TextInputType.emailAddress, //Show email-specific keyboard
                    validator: (value) {
                      //Validate email
                      if (value == null || !value.contains('@')) {
                        return 'Please enter a valid email address'; //Error message if email is invalid
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _email = value!; //Save the email to the _email variable
                    },
                  ),
                  //Password Input Field
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Password'), //Label for the password input field
                    obscureText: true, //Hide password characters
                    validator: (value) {
                      //Validate password
                      if (value == null || value.length < 6) {
                        return 'Password must be at least 6 characters long'; // Error message if password is too short
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _password = value!; //Save the password to the _password variable
                    },
                  ),
                  const SizedBox(height: 20), //Spacing
                  ElevatedButton(
                    onPressed: _login, //Call the _login function when pressed
                    child: const Text('Login'), //Button text
                  ),
                ],
              ),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage, //Error Messages
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}