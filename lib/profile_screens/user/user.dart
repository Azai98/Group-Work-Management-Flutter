class User {
  String image;
  String username;
  String email;
  String phone;
  String bio;

  // Constructor
  User(this.image,this.username,this.email,this.phone,this.bio,);

  Map<String, dynamic> toJson() => {
        'imagePath': image,
        'username': username,
        'email': email,
        'about': bio,
        'phone': phone,
      };

  Map<String, dynamic> updateName() => {
    'username': username,
  };

  Map<String, dynamic> updatePhone() => {
    'phone': phone,
  };

  Map<String, dynamic> updateBio() => {
    'bio': bio,
  };


}
