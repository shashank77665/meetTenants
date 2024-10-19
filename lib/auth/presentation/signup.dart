import 'package:flutter/material.dart';
import 'package:meettenants/auth/view/authfunction.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _isBroker = false;
  final _formKey = GlobalKey<FormState>();

  // Controllers to capture text input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Signup')),
      // This property ensures the UI adjusts when the keyboard is open
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        // Wrap content in a scrollable view
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: _formKey, // Key for the form to perform validation
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Name',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'E-Mail',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'E-Mail is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Password',
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                // Mobile number field, always shown
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: TextFormField(
                        controller: _mobileController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Mobile No (Optional if not a broker)',
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (_isBroker && (value == null || value.isEmpty)) {
                            return 'Mobile No is required for brokers';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('I am a broker'),
                      Switch(
                        value: _isBroker,
                        onChanged: (bool value) {
                          setState(() {
                            _isBroker = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      createUser(
                          context,
                          _emailController.text,
                          _passwordController.text,
                          _nameController.text,
                          _isBroker);
                    }
                  },
                  child: Text('Signup'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Existing User?'),
                    TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text('Login'))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
