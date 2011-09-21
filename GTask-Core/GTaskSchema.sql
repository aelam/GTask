

-- https://www.googleapis.com/tasks/v1/users/@me/lists?oauth_token=ya29.AHES6ZQzOXeVl9Jpv4djNefwKjhz3uKGDTrnFOCxu4Wi7qvmKDGMqw
/****
{
    "etag":
    "\"wlw5H5PUV7a3H2ESAfK5oImHSA0/3AG97lyej9DlGCEJ_eyn2WYfzow\"",
    "items":
    [
        {
            "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow",
            "kind" : "tasks#taskList",
            "selfLink" : "https://www.googleapis.com/tasks/v1/users/@me/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow",
            "title" : "TODO LIST"
        },
    ],
    "kind" : "tasks#taskLists"
}
*/

CREATE TABLE task_lists (
    id          INTEGER,
    kind        VARCHAR,
    self_link   VARCHAR,
    title       VARCHAR,
);

-- https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks?oauth_token=ya29.AHES6ZQzOXeVl9Jpv4djNefwKjhz3uKGDTrnFOCxu4Wi7qvmKDGMqw

/*
{
  "etag" : "\"wlw5H5PUV7a3H2ESAfK5oImHSA0/EnctuqfEbUjZOYyTxltXaXqUyFc\"",
  "items" : [
    {
      "completed" : "2011-08-28T16:20:37.000Z",
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo2NQ",
      "kind" : "tasks#task",
      "position" : "00000000000000164481",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo2NQ",
      "status" : "completed",
      "title" : "Gtask for Mac",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo2Ng",
      "kind" : "tasks#task",
      "position" : "00000000000000246722",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo2Ng",
      "status" : "needsAction",
      "title" : "Cfattributestring",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "due" : "2011-06-14T00:00:00.000Z",
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo2NA",
      "kind" : "tasks#task",
      "notes" : "Mew.org",
      "position" : "00000000000000257002",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo2NA",
      "status" : "needsAction",
      "title" : "设置mew",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo1OQ",
      "kind" : "tasks#task",
      "position" : "00000000000003947579",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo1OQ",
      "status" : "needsAction",
      "title" : "wxPython python Django 学习python ",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo1OA",
      "kind" : "tasks#task",
      "position" : "00000000000004029820",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo1OA",
      "status" : "needsAction",
      "title" : "iGoogle Tasks For Mac",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo2Mg",
      "kind" : "tasks#task",
      "position" : "00000000000004112061",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo2Mg",
      "status" : "needsAction",
      "title" : "wireshark 使用",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "completed" : "2011-08-28T16:20:37.000Z",
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo2MQ",
      "kind" : "tasks#task",
      "position" : "00000000000004276544",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo2MQ",
      "status" : "completed",
      "title" : "Reader 和 xmark some awesome links 整理",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "completed" : "2011-06-28T02:38:52.000Z",
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo2MA",
      "kind" : "tasks#task",
      "position" : "00000000000004605509",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo2MA",
      "status" : "completed",
      "title" : "backup systemn",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo2Mw",
      "kind" : "tasks#task",
      "position" : "00000000000004934474",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo2Mw",
      "status" : "needsAction",
      "title" : "awesome note",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo1Nw",
      "kind" : "tasks#task",
      "position" : "00000000000005263439",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo1Nw",
      "status" : "needsAction",
      "title" : "创建自己的工程模板",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo1Ng",
      "kind" : "tasks#task",
      "notes" : "Sync\nFile\n",
      "position" : "00000000000007895159",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo1Ng",
      "status" : "needsAction",
      "title" : "Xargs",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo1NA",
      "kind" : "tasks#task",
      "notes" : "下载\nSqlite\n",
      "position" : "00000000000015790319",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo1NA",
      "status" : "needsAction",
      "title" : "Core data",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "completed" : "2011-08-28T16:20:37.000Z",
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo1Mg",
      "kind" : "tasks#task",
      "notes" : "第二范式（2NF）完全依赖于主键[消除非主属性对主码的部分函数依赖] \n 第三范式（3NF）不依赖于其它非主！属性[消除传递依赖]  ",
      "position" : "00000000000019737899",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo1Mg",
      "status" : "completed",
      "title" : "第一范式（1NF）无重复的列",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "completed" : "2011-08-28T16:20:37.000Z",
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo0Nw",
      "kind" : "tasks#task",
      "position" : "00000000000021711689",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo0Nw",
      "status" : "completed",
      "title" : "捉放爱",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "completed" : "2011-08-28T16:20:40.000Z",
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo0Ng",
      "kind" : "tasks#task",
      "position" : "00000000000421075225",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo0Ng",
      "status" : "completed",
      "title" : "武昌杨家湾保利华都",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo0NQ",
      "kind" : "tasks#task",
      "notes" : "\n赎罪\n人民公敌\n水浒 公孙\n王的男人",
      "position" : "00000000000505290270",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo0NQ",
      "status" : "needsAction",
      "title" : "电影",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "completed" : "2011-08-28T16:20:40.000Z",
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo0NA",
      "kind" : "tasks#task",
      "notes" : "浦发银行广告曲",
      "position" : "00000000000589505315",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo0NA",
      "status" : "completed",
      "title" : "歌舞青春专辑",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo0Mw",
      "kind" : "tasks#task",
      "position" : "00000000000673720360",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo0Mw",
      "status" : "needsAction",
      "title" : "查找一个完整的xcode配置文件",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDozOQ",
      "kind" : "tasks#task",
      "notes" : "Binding \nCore Data \nBinding 与Core Data 结合",
      "position" : "00000000000757935405",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDozOQ",
      "status" : "needsAction",
      "title" : "Cocoa 结构",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo0MA",
      "kind" : "tasks#task",
      "notes" : "学习中",
      "position" : "00000000000842150450",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo0MA",
      "status" : "needsAction",
      "title" : "数据库",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "completed" : "2011-05-31T12:54:25.000Z",
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo0MQ",
      "kind" : "tasks#task",
      "position" : "00000000000926365495",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo0MQ",
      "status" : "completed",
      "title" : "Socket --",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "completed" : "2011-05-31T12:54:25.000Z",
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo0Mg",
      "kind" : "tasks#task",
      "position" : "00000000001010580540",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDo0Mg",
      "status" : "completed",
      "title" : "In app purchase",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDozNg",
      "kind" : "tasks#task",
      "position" : "00000000001094795585",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDozNg",
      "status" : "needsAction",
      "title" : "accessibilityHint",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDozNw",
      "kind" : "tasks#task",
      "position" : "00000000001179010630",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDozNw",
      "status" : "needsAction",
      "title" : "Tesseract",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "completed" : "2011-05-31T12:54:25.000Z",
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDozOA",
      "kind" : "tasks#task",
      "position" : "00000000001263225675",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDozOA",
      "status" : "completed",
      "title" : "OCR图形界面版）",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDozMA",
      "kind" : "tasks#task",
      "position" : "00000000001684300900",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDozMA",
      "status" : "needsAction",
      "title" : "学习C++ [!]",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "completed" : "2011-03-02T16:11:52.000Z",
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDoyNw",
      "kind" : "tasks#task",
      "position" : "00000000001768515945",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDoyNw",
      "status" : "completed",
      "title" : "Mac 开发学习",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDoxOQ",
      "kind" : "tasks#task",
      "notes" : "放弃了？",
      "position" : "00000000001852730990",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDoxOQ",
      "status" : "needsAction",
      "title" : "man for iPhone",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "completed" : "2011-05-21T01:02:34.000Z",
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDoxNw",
      "kind" : "tasks#task",
      "notes" : "- 基本二值化\n- 高级二值化\n- 边缘, 旋转\n- zbar 修改\n- AVFoundation pixel 的问题\n",
      "position" : "00000000001936946035",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDoxNw",
      "status" : "completed",
      "title" : "条码扫描研究",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDoyNg",
      "kind" : "tasks#task",
      "position" : "00000000002021161080",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDoyNg",
      "status" : "needsAction",
      "title" : "Gnu 开发学习",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDoyMw",
      "kind" : "tasks#task",
      "notes" : "Twitter youtube Facebook 浏览器\n",
      "position" : "00000000002273806215",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDoyMw",
      "status" : "needsAction",
      "title" : "SSH 客户端",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "completed" : "2011-03-10T05:28:57.000Z",
      "due" : "2011-12-08T00:00:00.000Z",
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDoyNQ",
      "kind" : "tasks#task",
      "position" : "00000000002358021260",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDoyNQ",
      "status" : "completed",
      "title" : "每天半小时英语 放弃了？",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDoyMA",
      "kind" : "tasks#task",
      "position" : "00000000002442236305",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDoyMA",
      "status" : "needsAction",
      "title" : "Google查找商品的API",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "completed" : "2011-02-05T17:03:18.000Z",
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDoyNA",
      "kind" : "tasks#task",
      "notes" : "It can sync with Google \nResearch Google API ",
      "position" : "00000000002526451350",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDoyNA",
      "status" : "completed",
      "title" : "Todo list for mac.",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDoyMg",
      "kind" : "tasks#task",
      "position" : "00000000002610666395",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDoyMg",
      "status" : "needsAction",
      "title" : "Python 验证码识别",
      "updated" : "2011-08-30T18:35:27.000Z"
    },
    {
      "id" : "MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDoxNg",
      "kind" : "tasks#task",
      "position" : "00000000002694881440",
      "selfLink" : "https://www.googleapis.com/tasks/v1/lists/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDow/tasks/MTI4MTA3OTcwNjkxODkyNzIyNDQ6MDoxNg",
      "status" : "needsAction",
      "title" : "facebook 集成",
      "updated" : "2011-08-30T18:35:27.000Z"
    }
  ],
  "kind" : "tasks#tasks"
}

*/


CREATE TABLE tasks (
    id          VARCHAR,
    kind        VARCHAR,
    self_link   VARCHAR,
    etag        VARCAHR,
    title
    notes
    updated
    position
    due
    hidden
    status
    deleted
    
    parent
)














