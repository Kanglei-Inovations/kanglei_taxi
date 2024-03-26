class Validator {
  static String? validateName({required String? name}) {
    if (name == null) {
      return null;
    }

    if (name.isEmpty) {
      return 'Name can\'t be empty';
    }

    return null;
  }

  static String? validateEmail({required String? email}) {
    if (email == null) {
      return null;
    }

    RegExp emailRegExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

    if (email.isEmpty) {
      return 'Email can\'t be empty';
    } else if (!emailRegExp.hasMatch(email)) {
      return 'Enter a correct email';
    }

    return null;
  }

  static String? validatePhone({required String? phone}) {
    if (phone == null) {
      return null;
    }
      if (phone.isEmpty) {
        return 'Phone no. can\'t be empty';
      } else if (phone.length != 10) {
        return 'Enter a phone no 10 digits';
      }

      return null;
  }


  static String? validatePassword({required String? password}) {
    if (password == null) {
      return null;
    }

    if (password.isEmpty) {
      return 'Password can\'t be empty';
    } else if (password.length < 6) {
      return 'Enter a password with length at least 6';
    }

    return null;
  }
  static String? confirmedPassword({required String? password1, required String? password2}) {
    if (password1 == password2) {
      return 'New password should not be the same as the current password';
    }

    if (password2!.isEmpty) {
      return 'Enter Confirmed Password';
    } else if (password1!.isEmpty) {
      return 'Enter Current Password';
    } else if (password1.length < 6) {
      return 'Enter Currect password with length at least 6';
    }
    else if (password2.length < 6) {
      return 'Enter new password with length at least 6';
    }
  }

}