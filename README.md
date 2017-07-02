# WP Cowsay

[![Build Status](https://travis-ci.org/kamataryo/wp-cowsay.svg)](https://travis-ci.org/kamataryo/wp-cowsay)
[![Wordpress official repository](https://img.shields.io/wordpress/v/wp-cowsay.svg)](https://wordpress.org/plugins/wp-cowsay/)

## Official Repository

https://wordpress.org/plugins/wp-cowsay/

## Contributing

```
$ git clone https://github.com/kamataryo/wp-cowsay
$ cd wp-cowsay
$ bash .bin/install-wp-tests.sh wordpress_test root '' localhost $WP_VERSION
$ composer install
$ phpunit
```

## Screen shots

1. type a shortcode.
![copy job url](./screenshot-1.png)

1. Cow says!
![copy build url](./screenshot-2.png)


## Deploy workflow

1. Push to master
2. test success
3. update tested WP VERSION
4. push back to master

0. npm version
1. push to tag
2. update plugin version
3. push back to master
4. svn commit
