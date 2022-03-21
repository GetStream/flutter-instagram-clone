import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../app/app.dart';
import '../app_widgets/app_widgets.dart';

/// {@template edit_profile_page}
/// Screen to edit a user's profile info.
/// {@endtemplate}
class EditProfileScreen extends StatelessWidget {
  /// {@macro edit_profile_page}
  const EditProfileScreen({
    Key? key,
  }) : super(key: key);

  /// Custom route to this screen. Animates from the bottom up.
  static Route get route => PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const EditProfileScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final tween = Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOutQuint));
          final offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    final streamagramUser = context
        .select<AppState, StreamagramUser?>((value) => value.streamagramUser);
    if (streamagramUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('You should not see this.\nUser data is empty.'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Cancel',
            style: (Theme.of(context).brightness == Brightness.dark)
                ? const TextStyle(color: AppColors.light)
                : const TextStyle(color: AppColors.dark),
          ),
        ),
        leadingWidth: 80,
        title: const Text(
          ' Edit profile',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
      body: ListView(
        children: [
          const _ChangeProfilePictureButton(),
          const Divider(
            color: Colors.grey,
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                const SizedBox(
                  width: 100,
                  child: Text(
                    'Name',
                    style: AppTextStyle.textStyleBoldMedium,
                  ),
                ),
                Text(
                  '${streamagramUser.fullName} ',
                  style: AppTextStyle.textStyleBoldMedium,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                const SizedBox(
                  width: 100,
                  child: Text(
                    'Username',
                    style: AppTextStyle.textStyleBoldMedium,
                  ),
                ),
                Text(
                  '${context.appState.user.id} ',
                  style: AppTextStyle.textStyleBoldMedium,
                ),
              ],
            ),
          ),
          const Divider(color: Colors.grey),
        ],
      ),
    );
  }
}

class _ChangeProfilePictureButton extends StatefulWidget {
  const _ChangeProfilePictureButton({
    Key? key,
  }) : super(key: key);

  @override
  __ChangeProfilePictureButtonState createState() =>
      __ChangeProfilePictureButtonState();
}

class __ChangeProfilePictureButtonState
    extends State<_ChangeProfilePictureButton> {
  final _picker = ImagePicker();

  Future<void> _changePicture() async {
    if (context.appState.isUploadingProfilePicture == true) {
      return;
    }

    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      await context.appState.updateProfilePhoto(pickedFile.path);
    } else {
      context.removeAndShowSnackbar('No picture selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    final streamagramUser = context
        .select<AppState, StreamagramUser>((value) => value.streamagramUser!);
    final isUploadingProfilePicture = context
        .select<AppState, bool>((value) => value.isUploadingProfilePicture);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 150,
            child: Center(
              child: isUploadingProfilePicture
                  ? const CircularProgressIndicator()
                  : GestureDetector(
                      onTap: _changePicture,
                      child: Avatar.huge(streamagramUser: streamagramUser),
                    ),
            ),
          ),
          GestureDetector(
            onTap: _changePicture,
            child: const Text('Change Profile Photo',
                style: AppTextStyle.textStyleAction),
          ),
        ],
      ),
    );
  }
}
