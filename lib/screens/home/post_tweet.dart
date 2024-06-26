
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:twitter/screens/home/rule-screen.dart';
import 'package:twitter/shared/loading.dart';
import 'package:twitter/widgets/group_brief.dart';
import 'package:twitter/widgets/quote_tweet.dart';
import '../../models/group.dart';
import '../../models/tweet.dart';
import '../../services/database_service.dart';
import '../../shared/global_variable.dart';

class PostTweetScreen extends StatefulWidget {
  PostTweetScreen({super.key, required this.postTweet, this.quote, this.groupId });
  late Function postTweet;
  late Tweet? quote;
  late String? groupId;
  @override
  State<PostTweetScreen> createState() => _PostTweetScreenState();
}

class _PostTweetScreenState extends State<PostTweetScreen> {

  ValueNotifier<List<XFile>> imagePicked = ValueNotifier([]);
  final TextEditingController _controller = TextEditingController();
  ValueNotifier<int> numOfWord = ValueNotifier(0);
  final ValueNotifier<bool> _canPost = ValueNotifier(false);
  final ValueNotifier<bool> _brief = ValueNotifier(false);
  final ValueNotifier<int> _audience = ValueNotifier(0);
  ValueNotifier<String> content = ValueNotifier("");
  ValueNotifier<int> personal = ValueNotifier(1);
  List<Group> groupList = [];
  bool _isLoad = true;
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  //Get list group user join
  Future<void> fetchData() async{
    try{
      groupList =  await DatabaseService().getGroupJoined();
      _isLoad = false;
      if(widget.groupId!=null){
        for(int index = 0; index < groupList.length; index++){
          Group group = groupList[index];
          if(group.groupIdAsString == widget.groupId){
            _audience.value = index+1;
          }
        }
      }
      setState(() {
      });
    }catch(e){
      print(e);
    }
  }

  // build view for imagePicked
  Widget buildListImage(List<XFile> images){
    if(images.length >1){
      List<Widget> result = [];
      for (var element in images) {
        Size size = ImageSizeGetter.getSize(FileInput(File(element.path)));
        result.add(ImagePicked(image: element, removeImage: removeImage,));
      }
      return SizedBox(
        height: 160,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: result,
        ),
      );
    }else if (images.length == 1){
      return ImagePicked(image: images[0], removeImage: removeImage,);
    }
    return const SizedBox(height: 0,);
  }
  //remove image in imagePicked
  void removeImage(XFile file){
    List<XFile> temp = List.from(imagePicked.value);
    temp.remove(file);
    imagePicked.value= temp;
    if(imagePicked.value.isEmpty && _brief.value){
      _brief.value = false;
    }
    print("image length: ${imagePicked.value.length}");
  }
  Widget buildPickPersonalView(int value){
    String content = "";
    late Icon icon;
    if(value == 1){
      content = "Everyone can reply";
      icon = const Icon(FontAwesomeIcons.earth, color: Colors.blue, size: 13,);
    }else if(value == 2){
      content = "Anyone follow you can reply";
      icon = const Icon(FontAwesomeIcons.user, color: Colors.blue, size: 13,);
    }else {
      content = "Just you can reply";
      icon = const Icon(FontAwesomeIcons.at, color: Colors.blue, size: 13,);
    }
    return Row(
      children: [
        icon,
        const SizedBox(width: 12,),
        Text(
          content,
          style: const TextStyle(
              color: Colors.blue,
              fontSize: 13
          ),
        )
      ],
    );
  }
  List<Widget> buildListGroup(){
    List<Widget> rs = [];
    for(int index = 0; index < groupList.length; index++){
      Group group = groupList[index];
      if(group.groupIdAsString == widget.groupId){
        _audience.value = index+1;
      }
      rs.add(GestureDetector(
          onTap: (){
            _audience.value = index+1;
            Navigator.pop(context);  
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: BriefGroup(img: group.groupImg, title: group.groupName,
                subTitle: group.groupMembers.length.toString(),
                isActive: _audience.value == index+1),
          )
      )
      );
    }
    return rs;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoad? const Loading(): SafeArea(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(top: 65, left: 15, right: 15),
              child: ListView(
                scrollDirection: Axis.vertical,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // show user avatar
                      Container(
                          alignment: Alignment.centerLeft,
                          height: 40,
                          width: 40,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Image.network(GlobalVariable.avatar),
                      ),
                      const SizedBox(width: 12,),
                      // content and media
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: (){
                                showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return Container(
                                        color: Colors.black,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  CupertinoIcons.minus,
                                                  color: Colors.white.withOpacity(0.8),
                                                  size: 40,
                                                )
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            const Align(
                                              alignment: Alignment.center,
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 20),
                                                child: Text(
                                                  "Choose audience",
                                                  style: TextStyle(
                                                    fontSize: 22,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 15,),
                                            //everyone
                                            GestureDetector(
                                              onTap: (){
                                                _audience.value = 0;
                                                Navigator.pop(context);
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  border: Border(
                                                    bottom: BorderSide(
                                                      color: Colors.white.withOpacity(0.4),
                                                      width: 0.15
                                                    ),
                                                    top: BorderSide(
                                                        color: Colors.white.withOpacity(0.4),
                                                        width: 0.15
                                                    ),
                                                  )
                                                ),
                                                child: BriefGroup(img: "", title:"Everyone", subTitle: "", isActive:_audience.value==0),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 12),
                                              child: Text(
                                                "My Communities",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            ...buildListGroup()
                                          ],
                                        ),
                                      );
                                    });
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(25),
                                        border: Border.all(color: Colors.blue, width: 0.8),
                                      ),
                                      child: Row(
                                        children: [
                                          ValueListenableBuilder(
                                              valueListenable: _audience,
                                              builder: (context, value, child){
                                                return Text(
                                                  value == 0? "Everyone": groupList[value-1].groupName,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14,
                                                    overflow: TextOverflow.ellipsis,

                                                  ),
                                                );
                                              }
                                          ) ,
                                          const SizedBox(width: 2,),
                                          const Icon(
                                            CupertinoIcons.chevron_down,
                                            size: 14,
                                            color: Colors.white,
                                          )
                                        ],
                                      )
                                  ),
                                ],
                              ),
                            ),
                            TextFormField(
                              controller:_controller ,
                              decoration: InputDecoration(
                                hintText: imagePicked.value.isNotEmpty ? "Add a comment...":"What's happening?",
                                hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 16
                                ),
                                border: InputBorder.none,
                              ),
                              maxLines: null,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  decoration: TextDecoration.none
                              ),
                              onChanged: (value){
                                  numOfWord.value = value.length;
                                  content.value = value;
                                  if(value.length >300){
                                    _canPost.value = false;
                                  }else if(value.isNotEmpty || imagePicked.value.isNotEmpty){
                                    _canPost.value = true;
                                  }else {
                                    _canPost.value = false;
                                  }
                              },
                            ),
                            if(imagePicked.value.isNotEmpty)...[
                              ValueListenableBuilder(
                                  valueListenable: imagePicked,
                                  builder: (context, value, child) {
                                    print("builded");
                                    return buildListImage(value);
                                  },
                              ),
                              const SizedBox(height: 12,)
                            ],
                            if(widget.quote != null)...[
                              ValueListenableBuilder(
                                  valueListenable: _brief,
                                  builder: (context, value, child){
                                    return QuoteTweet(quote: widget.quote, brief: value);
                                  },

                              )
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100,)
                ],
              ),
            ),
            // app bar for this screen
            Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black,
                  padding: const EdgeInsets.only(top: 12, right: 15, left: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: const Icon(FontAwesomeIcons.close, size: 24,),
                      ),
                      ValueListenableBuilder(
                        valueListenable: _canPost,
                        builder: (context, value, child){
                          return TextButton(
                            onPressed: value?(){
                              String groupId = "";
                              if(_audience.value != 0){
                                groupId = groupList[_audience.value-1].groupIdAsString;
                              }
                              Tweet tweet = Tweet(idAsString: "", content: content.value, uid: GlobalVariable.currentUser!.myUser.uid, imgLinks: [], videoLinks: [],
                                uploadDate: DateTime.now(), user: GlobalVariable.currentUser, totalComment: 0, totalLike: 0, personal: personal.value ,
                                isLike: false,groupName: groupId, repost: widget.quote, commentTweetId: '', replyTo: null, totalRepost: 0, isRepost: false,
                                isBookmark: false, totalBookmark: 0, totalQuote: 0,  );
                              widget.postTweet(imagePicked.value, tweet);
                              Navigator.pop(context);
                            }:null,
                            style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.blue.withOpacity(0.6),
                                disabledForegroundColor: Colors.white.withOpacity(0.6),
                                textStyle: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)
                                )
                            ),
                            child: const Text(
                                "Post"
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
            ),
            // some setting about personal
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.black,
                          border: Border(
                              top: BorderSide(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 0.5
                              )
                          )
                      ),
                      child: ValueListenableBuilder(
                          valueListenable: _audience,
                          builder: (context, value, child){
                            if(value!=0){
                              return GestureDetector(
                                onTap: (){
                                  Navigator.push(context,
                                      MaterialPageRoute(
                                          builder: (context)=> CommunityRulesScreen(
                                              ruleNameList: groupList[_audience.value-1].rulesName,
                                              ruleDesList: groupList[_audience.value-1].rulesContent)
                                      )
                                  );
                                },
                                child: Row(
                                  children: [
                                    Icon(CupertinoIcons.person_2_fill, color: Colors.white.withOpacity(0.8),size: 16,),
                                    const SizedBox(width: 12,),
                                    Text(
                                      "Community menbers can reply",
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 13
                                      ),
                                    ),
                                    const SizedBox(width: 6,),
                                    Icon(CupertinoIcons.circle_fill, color: Colors.white.withOpacity(0.8),size: 3,),
                                    const SizedBox(width: 6,),
                                    const Text(
                                      "Rules",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }else {
                              return GestureDetector(
                                onTap: (){
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return Container(
                                          height: MediaQuery.of(context).size.height * 0.5,
                                          color: Colors.black,
                                          child: Column(
                                            children: [
                                              const Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    CupertinoIcons.minus,
                                                    color: Colors.white,
                                                    size: 40,
                                                  )
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              const Align(
                                                alignment: Alignment.centerLeft,
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                                  child: Text(
                                                    "Who can reply?",
                                                    style: TextStyle(
                                                      fontSize: 22,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 15,),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                                  child: Text(
                                                    "Pick who can reply to this post. Keep in mind that anyone mentioned can always reply.",
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white.withOpacity(0.5),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              GestureDetector(
                                                onTap: (){
                                                  Navigator.pop(context);
                                                  personal.value = 1;
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal:20 ),
                                                  child: SizedBox(
                                                      width: MediaQuery.of(context).size.width,
                                                      child: Row(
                                                        children: [
                                                          Stack(
                                                            children: [
                                                              Container(
                                                                width: 50,
                                                                height: 50,
                                                                margin: const EdgeInsets.all(4),
                                                                decoration: BoxDecoration(
                                                                    color: Colors.blue,
                                                                    borderRadius: BorderRadius.circular(25)
                                                                ),
                                                                child: const Icon(FontAwesomeIcons.earth, size: 20),
                                                              ),
                                                              Visibility(
                                                                  visible: personal.value == 1,
                                                                  child: Positioned(
                                                                    right: 0,
                                                                    bottom: 0,
                                                                    child: Container(
                                                                      height: 20,
                                                                      width: 20,
                                                                      decoration: BoxDecoration(
                                                                          color: CupertinoColors.systemGreen,
                                                                          borderRadius: BorderRadius.circular(10),
                                                                          border: Border.all(
                                                                              width: 1.5,
                                                                              color: Colors.black
                                                                          )
                                                                      ),
                                                                      child: const Icon(FontAwesomeIcons.check, color: Colors.black,size: 10,),
                                                                    ),
                                                                  )
                                                              )
                                                            ],
                                                          ),
                                                          const SizedBox(width: 12,),
                                                          const Text(
                                                            "Everyone",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color: Colors.white,
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 20,),
                                              GestureDetector(
                                                onTap: (){
                                                  Navigator.pop(context);
                                                  personal.value = 2;
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal:20 ),
                                                  child: SizedBox(
                                                      width: MediaQuery.of(context).size.width,
                                                      child: Row(
                                                        children: [
                                                          Stack(
                                                            children: [
                                                              Container(
                                                                width: 50,
                                                                height: 50,
                                                                margin: const EdgeInsets.all(4),
                                                                decoration: BoxDecoration(
                                                                    color: Colors.blue,
                                                                    borderRadius: BorderRadius.circular(25)
                                                                ),
                                                                child: const Icon(FontAwesomeIcons.user, size: 20),
                                                              ),
                                                              Visibility(
                                                                  visible: personal.value == 2,
                                                                  child: Positioned(
                                                                    right: 0,
                                                                    bottom: 0,
                                                                    child: Container(
                                                                      height: 20,
                                                                      width: 20,
                                                                      decoration: BoxDecoration(
                                                                          color: CupertinoColors.systemGreen,
                                                                          borderRadius: BorderRadius.circular(10),
                                                                          border: Border.all(
                                                                              width: 1.5,
                                                                              color: Colors.black
                                                                          )
                                                                      ),
                                                                      child: const Icon(FontAwesomeIcons.check, color: Colors.black,size: 10,),
                                                                    ),
                                                                  )
                                                              )
                                                            ],
                                                          ),
                                                          const SizedBox(width: 12,),
                                                          const Text(
                                                            "Anyone follow you",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color: Colors.white,
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 20,),
                                              GestureDetector(
                                                onTap: (){
                                                  Navigator.pop(context);
                                                  personal.value = 3;
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal:20 ),
                                                  child: SizedBox(
                                                      width: MediaQuery.of(context).size.width,
                                                      child: Row(
                                                        children: [
                                                          Stack(
                                                            children: [
                                                              Container(
                                                                width: 50,
                                                                height: 50,
                                                                margin: const EdgeInsets.all(4),
                                                                decoration: BoxDecoration(
                                                                    color: Colors.blue,
                                                                    borderRadius: BorderRadius.circular(25)
                                                                ),
                                                                child: const Icon(FontAwesomeIcons.at, size: 20),
                                                              ),
                                                              Visibility(
                                                                  visible: personal.value == 3,
                                                                  child: Positioned(
                                                                    right: 0,
                                                                    bottom: 0,
                                                                    child: Container(
                                                                      height: 20,
                                                                      width: 20,
                                                                      decoration: BoxDecoration(
                                                                          color: CupertinoColors.systemGreen,
                                                                          borderRadius: BorderRadius.circular(10),
                                                                          border: Border.all(
                                                                              width: 1.5,
                                                                              color: Colors.black
                                                                          )
                                                                      ),
                                                                      child: const Icon(FontAwesomeIcons.check, color: Colors.black,size: 10,),
                                                                    ),
                                                                  )
                                                              )
                                                            ],
                                                          ),
                                                          const SizedBox(width: 12,),
                                                          const Text(
                                                            "Just you",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color: Colors.white,
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      });
                                },
                                child: ValueListenableBuilder(
                                    valueListenable: personal,
                                    builder: (context, value, child){
                                      return buildPickPersonalView(value);
                                    }
                                ),
                              );
                            }
                          }
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.black,
                          border: Border(
                              top: BorderSide(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 0.5
                              )
                          )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                              onTap:()async{
                                if(imagePicked.value.length < 4){
                                  List<XFile> images = await ImagePicker().pickMultiImage(
                                      maxWidth: 1920,
                                      maxHeight: 1080,
                                      imageQuality: 100
                                  );
                                  if(images.length>4){
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        // backgroundColor: Colors.transparent,
                                        width: 2.6*MediaQuery.of(context).size.width/4,
                                        behavior: SnackBarBehavior.floating,
                                        content: const Text('The number of selected photos is more than 4. Therefore, the first 4 images selected will be kept.'),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14)
                                        ),
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                    imagePicked.value = images.sublist(0, 4);
                                  }else {
                                    imagePicked.value = images;
                                  }
                                  if(!_brief.value){
                                    _brief.value = true;
                                  }
                                  _canPost.value = true;
                                  setState(() {

                                  });
                                                                }
                              },
                              child: Icon(FontAwesomeIcons.image, color: imagePicked.value.length == 4 ? Colors.blue.withOpacity(0.7):Colors.blue, size: 20,)
                          ),
                          ValueListenableBuilder(
                            valueListenable: numOfWord,
                            builder: (context, value, child) {
                              return SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  backgroundColor: Colors.white.withOpacity(0.4),
                                  strokeWidth: value/300 >1 ? 3: 2,
                                  value: (value/300).clamp(0, 1), // Set the value between 0.0 and 1.0
                                  valueColor: AlwaysStoppedAnimation<Color>(value/300>1 ? Colors.red: Colors.blue), // Set the color
                                ),
                              );
                            }
                          )
                        ],
                      ),
                    )
                  ],
                )
            )
          ],
        )
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// image item after choosed
class ImagePicked extends StatelessWidget {
  const ImagePicked({super.key, required this.image, required this.removeImage});
  final XFile image;
  final Function removeImage;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(26.0),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Image.file(File(image.path), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          right: 12,
          top: 12,
          child: GestureDetector(
            onTap: (){
              removeImage(image);
            },
            child: Container(
              alignment: Alignment.center,
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(50)
              ),
              child: const Icon(FontAwesomeIcons.close, size: 16,color: Colors.black,),
            ),
          ),
        )
      ],
    );
  }
}

