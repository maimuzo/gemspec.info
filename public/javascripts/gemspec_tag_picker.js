function add_tag_name(tag_name){
  old_names = $j('#tag_name').attr('value');
  if(old_names == $j('#tag_name').attr('title')){
    old_names = "";
    $j('#tag_name').trigger("focus");
  }
  if("" == old_names){
    add_name_set = tag_name;
  }else{
    add_name_set = ', ' + tag_name;
  }
  $j('#tag_name').attr('value', old_names + add_name_set);
}
