const exec = require('cordova/exec');
const CDVVideoPlayer = {
    prepare_play_video:function (success,option){
        exec(success,null,'CDVVideoPlayer','prepare_play_video',[option]);
    },
    play_video:function (option){
        exec(null,null,'CDVVideoPlayer','play_video',[option]);
    },
    pause_video:function (){
        exec(null,null,'CDVVideoPlayer','pause_video',[]);
    },
    resume_video:function (){
        exec(null,null,'CDVVideoPlayer','resume_video',[]);
    },
    end_play_video:function (){
        exec(null,null,'CDVVideoPlayer','end_play_video',[]);
    }
};
module.exports = CDVVideoPlayer;
