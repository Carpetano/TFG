import 'package:codigo/global_settings.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:codigo/supabase_manager.dart';
import 'package:codigo/Objetos/user_object.dart';

// Profile page to visualize data from the logged in user
// TODO implement user profile picture
class PerfilPage extends StatefulWidget {
  // Page constructor
  const PerfilPage({super.key});

  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  // User object to extract the data from
  UserObject? _user;

  // Image url (Unused but will be added in future)
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  /// Displays a snackbar message at the bottom of the screen
  /// This function creates a snackbar with the provided message, text color,
  /// and background color, then displays it using the ScaffoldMessenger
  ///
  /// - [message]: The text content of the snackbar
  /// - [textColor]: The color of the text inside the snackbar
  /// - [bgColor]: The background color of the snackbar
  void showSnackBar(String message, Color textColor, Color bgColor) {
    var snackBar = SnackBar(
      content: DefaultTextStyle(
        style: TextStyle(color: textColor),
        child: Text(message),
      ),
      backgroundColor: bgColor,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _loadUser() async {
    final user = await SupabaseManager.instance.getCurrentUser();
    setState(() {
      _user = user;
      _profileImageUrl = user?.profileImageUrl;
    });
  }

  /// Seleccionar y subir una imagen
  Future<void> _pickAndUploadImage() async {
    showSnackBar("Porfavor seleccione una imagen", Colors.white, Colors.black);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && _user != null) {
      // Subir imagen a Supabase Storage (pasa directamente `XFile`)
      String? imageUrl = await SupabaseManager.instance.uploadProfilePicture(
        pickedFile,
        _user!.authId,
      );

      if (imageUrl != null) {
        setState(() {
          _profileImageUrl = imageUrl; // Actualizar imagen en pantalla
        });
        print("Imagen subida con éxito: $imageUrl");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.translate('profile')),
        backgroundColor: Colors.blueAccent,
      ),
      body:
          _user == null
              ? const Center(child: CircularProgressIndicator())
              : Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Foto de perfil con opción de cambiar
                      GestureDetector(
                        onTap:
                            _pickAndUploadImage, // 📌 Al hacer clic, permite cambiar foto
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              _profileImageUrl != null
                                  ? NetworkImage(_profileImageUrl!)
                                  : const AssetImage(
                                        'assets/profile_placeholder.png',
                                      )
                                      as ImageProvider,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "${_user!.firstName} ${_user!.lastName} ${_user!.secondLastName}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _user!.email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _ProfileInfoRow(
                              icon: Icons.phone,
                              label: Translations.translate('phone'),
                              value: _user!.phone,
                            ),
                            const Divider(),
                            _ProfileInfoRow(
                              icon: Icons.badge,
                              label: Translations.translate('role'),
                              value: _user!.role,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent),
        const SizedBox(width: 10),
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
