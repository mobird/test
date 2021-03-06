var NAVTREE =
[
  [ "CocosDenshion Mac OS X", "index.html", [
    [ "Class List", "annotated.html", [
      [ "AVAudioPlayer", "interface_a_v_audio_player.html", null ],
      [ "<AVAudioPlayerDelegate>", "protocol_a_v_audio_player_delegate-p.html", null ],
      [ "AVAudioSession", "interface_a_v_audio_session.html", null ],
      [ "<AVAudioSessionDelegate>", "protocol_a_v_audio_session_delegate-p.html", null ],
      [ "bufferInfo", "structbuffer_info.html", null ],
      [ "CDAsynchBufferLoader", "interface_c_d_asynch_buffer_loader.html", null ],
      [ "CDAsynchInitialiser", "interface_c_d_asynch_initialiser.html", null ],
      [ "<CDAudioInterruptProtocol>", "protocol_c_d_audio_interrupt_protocol-p.html", null ],
      [ "CDAudioInterruptTargetGroup", "interface_c_d_audio_interrupt_target_group.html", null ],
      [ "CDAudioManager", "interface_c_d_audio_manager.html", null ],
      [ "<CDAudioTransportProtocol>", "protocol_c_d_audio_transport_protocol-p.html", null ],
      [ "CDBufferLoadRequest", "interface_c_d_buffer_load_request.html", null ],
      [ "CDBufferManager", "interface_c_d_buffer_manager.html", null ],
      [ "CDFloatInterpolator", "interface_c_d_float_interpolator.html", null ],
      [ "CDLongAudioSource", "interface_c_d_long_audio_source.html", null ],
      [ "<CDLongAudioSourceDelegate>", "protocol_c_d_long_audio_source_delegate-p.html", null ],
      [ "CDLongAudioSourceFader", "interface_c_d_long_audio_source_fader.html", null ],
      [ "CDPropertyModifier", "interface_c_d_property_modifier.html", null ],
      [ "CDSoundEngine", "interface_c_d_sound_engine.html", null ],
      [ "CDSoundEngineFader", "interface_c_d_sound_engine_fader.html", null ],
      [ "CDSoundSource", "interface_c_d_sound_source.html", null ],
      [ "CDSoundSourceFader", "interface_c_d_sound_source_fader.html", null ],
      [ "CDSoundSourcePanner", "interface_c_d_sound_source_panner.html", null ],
      [ "CDSoundSourcePitchBender", "interface_c_d_sound_source_pitch_bender.html", null ],
      [ "CDUtilities", "interface_c_d_utilities.html", null ],
      [ "CDXPropertyModifierAction", "interface_c_d_x_property_modifier_action.html", null ],
      [ "SimpleAudioEngine", "interface_simple_audio_engine.html", null ],
      [ "sourceGroup", "structsource_group.html", null ],
      [ "sourceInfo", "structsource_info.html", null ]
    ] ],
    [ "Class Index", "classes.html", null ],
    [ "Class Hierarchy", "hierarchy.html", [
      [ "AVAudioPlayer", "interface_a_v_audio_player.html", null ],
      [ "<AVAudioPlayerDelegate>", "protocol_a_v_audio_player_delegate-p.html", [
        [ "CDLongAudioSource", "interface_c_d_long_audio_source.html", null ]
      ] ],
      [ "AVAudioSession", "interface_a_v_audio_session.html", null ],
      [ "<AVAudioSessionDelegate>", "protocol_a_v_audio_session_delegate-p.html", [
        [ "CDAudioManager", "interface_c_d_audio_manager.html", null ]
      ] ],
      [ "bufferInfo", "structbuffer_info.html", null ],
      [ "CDAsynchBufferLoader", "interface_c_d_asynch_buffer_loader.html", null ],
      [ "CDAsynchInitialiser", "interface_c_d_asynch_initialiser.html", null ],
      [ "<CDAudioInterruptProtocol>", "protocol_c_d_audio_interrupt_protocol-p.html", [
        [ "CDAudioInterruptTargetGroup", "interface_c_d_audio_interrupt_target_group.html", null ],
        [ "CDAudioManager", "interface_c_d_audio_manager.html", null ],
        [ "CDLongAudioSource", "interface_c_d_long_audio_source.html", null ],
        [ "CDSoundEngine", "interface_c_d_sound_engine.html", null ],
        [ "CDSoundSource", "interface_c_d_sound_source.html", null ],
        [ "SimpleAudioEngine", "interface_simple_audio_engine.html", null ]
      ] ],
      [ "<CDAudioTransportProtocol>", "protocol_c_d_audio_transport_protocol-p.html", [
        [ "CDSoundSource", "interface_c_d_sound_source.html", null ]
      ] ],
      [ "CDBufferLoadRequest", "interface_c_d_buffer_load_request.html", null ],
      [ "CDBufferManager", "interface_c_d_buffer_manager.html", null ],
      [ "CDFloatInterpolator", "interface_c_d_float_interpolator.html", null ],
      [ "<CDLongAudioSourceDelegate>", "protocol_c_d_long_audio_source_delegate-p.html", [
        [ "CDAudioManager", "interface_c_d_audio_manager.html", null ]
      ] ],
      [ "CDPropertyModifier", "interface_c_d_property_modifier.html", [
        [ "CDLongAudioSourceFader", "interface_c_d_long_audio_source_fader.html", null ],
        [ "CDSoundEngineFader", "interface_c_d_sound_engine_fader.html", null ],
        [ "CDSoundSourceFader", "interface_c_d_sound_source_fader.html", null ],
        [ "CDSoundSourcePanner", "interface_c_d_sound_source_panner.html", null ],
        [ "CDSoundSourcePitchBender", "interface_c_d_sound_source_pitch_bender.html", null ]
      ] ],
      [ "CDUtilities", "interface_c_d_utilities.html", null ],
      [ "CDXPropertyModifierAction", "interface_c_d_x_property_modifier_action.html", null ],
      [ "sourceGroup", "structsource_group.html", null ],
      [ "sourceInfo", "structsource_info.html", null ]
    ] ],
    [ "Class Members", "functions.html", null ],
    [ "File List", "files.html", [
      [ "CocosDenshion.h", "_cocos_denshion_8h.html", null ]
    ] ],
    [ "File Members", "globals.html", null ]
  ] ]
];

function createIndent(o,domNode,node,level)
{
  if (node.parentNode && node.parentNode.parentNode)
  {
    createIndent(o,domNode,node.parentNode,level+1);
  }
  var imgNode = document.createElement("img");
  if (level==0 && node.childrenData)
  {
    node.plus_img = imgNode;
    node.expandToggle = document.createElement("a");
    node.expandToggle.href = "javascript:void(0)";
    node.expandToggle.onclick = function() 
    {
      if (node.expanded) 
      {
        $(node.getChildrenUL()).slideUp("fast");
        if (node.isLast)
        {
          node.plus_img.src = node.relpath+"ftv2plastnode.png";
        }
        else
        {
          node.plus_img.src = node.relpath+"ftv2pnode.png";
        }
        node.expanded = false;
      } 
      else 
      {
        expandNode(o, node, false);
      }
    }
    node.expandToggle.appendChild(imgNode);
    domNode.appendChild(node.expandToggle);
  }
  else
  {
    domNode.appendChild(imgNode);
  }
  if (level==0)
  {
    if (node.isLast)
    {
      if (node.childrenData)
      {
        imgNode.src = node.relpath+"ftv2plastnode.png";
      }
      else
      {
        imgNode.src = node.relpath+"ftv2lastnode.png";
        domNode.appendChild(imgNode);
      }
    }
    else
    {
      if (node.childrenData)
      {
        imgNode.src = node.relpath+"ftv2pnode.png";
      }
      else
      {
        imgNode.src = node.relpath+"ftv2node.png";
        domNode.appendChild(imgNode);
      }
    }
  }
  else
  {
    if (node.isLast)
    {
      imgNode.src = node.relpath+"ftv2blank.png";
    }
    else
    {
      imgNode.src = node.relpath+"ftv2vertline.png";
    }
  }
  imgNode.border = "0";
}

function newNode(o, po, text, link, childrenData, lastNode)
{
  var node = new Object();
  node.children = Array();
  node.childrenData = childrenData;
  node.depth = po.depth + 1;
  node.relpath = po.relpath;
  node.isLast = lastNode;

  node.li = document.createElement("li");
  po.getChildrenUL().appendChild(node.li);
  node.parentNode = po;

  node.itemDiv = document.createElement("div");
  node.itemDiv.className = "item";

  node.labelSpan = document.createElement("span");
  node.labelSpan.className = "label";

  createIndent(o,node.itemDiv,node,0);
  node.itemDiv.appendChild(node.labelSpan);
  node.li.appendChild(node.itemDiv);

  var a = document.createElement("a");
  node.labelSpan.appendChild(a);
  node.label = document.createTextNode(text);
  a.appendChild(node.label);
  if (link) 
  {
    a.href = node.relpath+link;
  } 
  else 
  {
    if (childrenData != null) 
    {
      a.className = "nolink";
      a.href = "javascript:void(0)";
      a.onclick = node.expandToggle.onclick;
      node.expanded = false;
    }
  }

  node.childrenUL = null;
  node.getChildrenUL = function() 
  {
    if (!node.childrenUL) 
    {
      node.childrenUL = document.createElement("ul");
      node.childrenUL.className = "children_ul";
      node.childrenUL.style.display = "none";
      node.li.appendChild(node.childrenUL);
    }
    return node.childrenUL;
  };

  return node;
}

function showRoot()
{
  var headerHeight = $("#top").height();
  var footerHeight = $("#nav-path").height();
  var windowHeight = $(window).height() - headerHeight - footerHeight;
  navtree.scrollTo('#selected',0,{offset:-windowHeight/2});
}

function expandNode(o, node, imm)
{
  if (node.childrenData && !node.expanded) 
  {
    if (!node.childrenVisited) 
    {
      getNode(o, node);
    }
    if (imm)
    {
      $(node.getChildrenUL()).show();
    } 
    else 
    {
      $(node.getChildrenUL()).slideDown("fast",showRoot);
    }
    if (node.isLast)
    {
      node.plus_img.src = node.relpath+"ftv2mlastnode.png";
    }
    else
    {
      node.plus_img.src = node.relpath+"ftv2mnode.png";
    }
    node.expanded = true;
  }
}

function getNode(o, po)
{
  po.childrenVisited = true;
  var l = po.childrenData.length-1;
  for (var i in po.childrenData) 
  {
    var nodeData = po.childrenData[i];
    po.children[i] = newNode(o, po, nodeData[0], nodeData[1], nodeData[2],
        i==l);
  }
}

function findNavTreePage(url, data)
{
  var nodes = data;
  var result = null;
  for (var i in nodes) 
  {
    var d = nodes[i];
    if (d[1] == url) 
    {
      return new Array(i);
    }
    else if (d[2] != null) // array of children
    {
      result = findNavTreePage(url, d[2]);
      if (result != null) 
      {
        return (new Array(i).concat(result));
      }
    }
  }
  return null;
}

function initNavTree(toroot,relpath)
{
  var o = new Object();
  o.toroot = toroot;
  o.node = new Object();
  o.node.li = document.getElementById("nav-tree-contents");
  o.node.childrenData = NAVTREE;
  o.node.children = new Array();
  o.node.childrenUL = document.createElement("ul");
  o.node.getChildrenUL = function() { return o.node.childrenUL; };
  o.node.li.appendChild(o.node.childrenUL);
  o.node.depth = 0;
  o.node.relpath = relpath;

  getNode(o, o.node);

  o.breadcrumbs = findNavTreePage(toroot, NAVTREE);
  if (o.breadcrumbs == null)
  {
    o.breadcrumbs = findNavTreePage("index.html",NAVTREE);
  }
  if (o.breadcrumbs != null && o.breadcrumbs.length>0)
  {
    var p = o.node;
    for (var i in o.breadcrumbs) 
    {
      var j = o.breadcrumbs[i];
      p = p.children[j];
      expandNode(o,p,true);
    }
    p.itemDiv.className = p.itemDiv.className + " selected";
    p.itemDiv.id = "selected";
    $(window).load(showRoot);
  }
}

