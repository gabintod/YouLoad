import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class VideoTile extends StatelessWidget {
  final Video video;
  final void Function()? onTap;

  const VideoTile(this.video, {Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              video.thumbnails.mediumResUrl,
              errorBuilder: (context, error, stacktrace) => Image.network(
                video.thumbnails.standardResUrl,
                errorBuilder: (context, error, stacktrace) => Image.network(
                  video.thumbnails.lowResUrl,
                  fit: BoxFit.cover,
                ),
                fit: BoxFit.cover,
              ),
              fit: BoxFit.cover,
            ),
          ),
          ListTile(
            // leading: FutureBuilder<Channel>(
            //   future: YoutubeExplode().channels.get(video.channelId),
            //   builder: (context, snapshot) {
            //     if (snapshot.hasData) {
            //       return Container(
            //         width: 40,
            //         height: 40,
            //         clipBehavior: Clip.antiAlias,
            //         decoration: BoxDecoration(
            //           shape: BoxShape.circle,
            //           image: DecorationImage(
            //             image: NetworkImage(
            //               snapshot.data!.logoUrl,
            //             ),
            //             fit: BoxFit.fill,
            //           ),
            //         ),
            //       );
            //     }
            //     return Container(
            //       width: 40,
            //       height: 40,
            //       clipBehavior: Clip.antiAlias,
            //       decoration: const BoxDecoration(
            //         shape: BoxShape.circle,
            //       ),
            //     );
            //   },
            // ),
            title: Text(
              video.title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(video.author),
          ),
          const SizedBox(height: 10),
        ],
      ),
      onTap: onTap,
    );
  }
}
