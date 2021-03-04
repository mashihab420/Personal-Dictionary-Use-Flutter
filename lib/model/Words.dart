class Words {
  int id;
  String english;
  String bangla;


  Words(
      {this.id,
        this.english,
        this.bangla,
      });

  Words.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    english = json['english'];
    bangla = json['bangla'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['english'] = this.english;
    data['bangla'] = this.bangla;
    return data;
  }
}