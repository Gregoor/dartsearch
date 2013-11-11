import 'dart:html';

int menuSize = 0;

attachMenuListeners(HtmlElement container, 
	{onRandomLevel, onLoadLevel, onSearch(searchId), onClearSearch}
) {
	HtmlElement searchBar = container.querySelector('.searchBar');
	var showSearchBar = () => searchBar.classes.remove('hidden');
	
	TextInputElement widthInput = container.querySelector('input.width');
	TextInputElement heightInput = container.querySelector('input.height');
	
	container.querySelector("button.randomLevel").onClick.listen((e) {
		showSearchBar();
		onRandomLevel(int.parse(widthInput.value), int.parse(heightInput.value));
	});
	
	FileReader reader = new FileReader();
	
	FileUploadInputElement levelUpload = container.querySelector("input.uploadLevel");
	levelUpload.onChange.listen((e) => reader.readAsText(levelUpload.files[0].slice()));
	
	reader.onLoad.listen((e) {
		showSearchBar();
		onLoadLevel(reader.result);
	});
	
	searchBar.querySelectorAll('button').onClick.listen((MouseEvent event) {
			HtmlElement el = event.currentTarget;
			if (el.classes.contains('clear')) onClearSearch();
			else onSearch(el.attributes['data-search']);
	});
	
	menuSize = container.scrollHeight;
}