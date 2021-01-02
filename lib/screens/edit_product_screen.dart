import 'package:flutter/material.dart';
import 'package:my_shop/providers/product.dart';
import 'package:my_shop/providers/products.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode(); //now its automatic on normal approach
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  var isInit = true;
  var isLoading = false;
  var _product = Product(
    id: null,
    title: null,
    description: null,
    price: null,
    imageUrl: null,
  );

  Map<String, String> _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imgURL': ''
  };

  Future<void> _saveForm() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        isLoading = true;
      });
      //context is available in state class

      try {
        if (_product.id == null) {
          await Provider.of<Products>(context, listen: false)
              .addProduct(_product);
        } else {
          await Provider.of<Products>(context, listen: false)
              .updateProduct(_product);
        }
      } catch (error) {
        await showDialog<Null>(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An error occurred!'),
                  content: Text('Something went wrong.'),
                  actions: [
                    FlatButton(
                      child: Text('Okay'),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    )
                  ],
                ));
      }
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _product =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title': _product.title,
          'description': _product.description,
          'price': _product.price.toString(),
          'imgURL': ''
        };
      }
      _imageUrlController.text = _product.imageUrl;
      isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();

    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      //to ask for image text if(_imageUrlController.text...)
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
              backgroundColor: Colors.black12,
            ))
          : Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _initValues['title'],
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value.isEmpty) return 'Title must not be empty';
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      decoration: InputDecoration(
                        labelText: 'Title',
                      ),
                      onSaved: (value) => {
                        _product = Product(
                          id: _product.id,
                          title: value,
                          description: _product.description,
                          price: _product.price,
                          imageUrl: _product.imageUrl,
                          isFavorite: _product.isFavorite,
                        )
                      },
                    ),
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      initialValue: _initValues['price'],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Price',
                      ),
                      focusNode: _priceFocusNode,
                      onSaved: (value) => {
                        _product = Product(
                          id: _product.id,
                          title: _product.title,
                          description: _product.description,
                          price: double.parse(value),
                          imageUrl: _product.imageUrl,
                          isFavorite: _product.isFavorite,
                        ),
                      },
                      validator: (value) {
                        if (value.isEmpty) return 'Title must not be empty';
                        if (double.tryParse(value) == null)
                          return 'Please enter a valid number';
                        if (double.parse(value) <= 0)
                          return 'Please enter a number greater than 0';
                        return null;
                      },
                    ),
                    TextFormField(
                      textInputAction: TextInputAction.newline,
                      initialValue: _initValues['description'],
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                      ),
                      onSaved: (value) => {
                        _product = Product(
                          id: _product.id,
                          title: _product.title,
                          description: value,
                          price: _product.price,
                          imageUrl: _product.imageUrl,
                          isFavorite: _product.isFavorite,
                        )
                      },
                      validator: (value) {
                        if (value.isEmpty)
                          return 'Description must not be empty';
                        if (value.length < 10)
                          return 'Description should be at least 10 characters long.';
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, right: 10, left: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Center(child: Text('Enter URL'))
                              : Image.network(
                                  _imageUrlController.text,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onSaved: (value) => {
                              _product = Product(
                                isFavorite: _product.isFavorite,
                                id: _product.id,
                                title: _product.title,
                                description: _product.description,
                                price: _product.price,
                                imageUrl: value,
                              )
                            },
                            validator: (value) {
                              if (value.isEmpty)
                                return 'Please enter an image URL';
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https'))
                                return 'please enter a valid URL';
                              if (!value.endsWith('.png') &&
                                  !value.endsWith('.jpg') &&
                                  !value.endsWith('jpeg') &&
                                  !value.endsWith('gif'))
                                return 'Please enter a valid image URL';

                              return null;
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
