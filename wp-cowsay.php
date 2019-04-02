<?php
/*
Plugin Name: WP Cowsay
Plugin URI: https://github.com/kamataryo/wp-cowsay
Description: Enable Cowsay shortcode!
Author: kamataryo
Version: 0.1.13
Author URI: http://biwako.io/
*/

$cowsay = new Cowsay();
$cowsay->register();

/**
 * Cowsay
 */
class Cowsay {

	/**
	 * shortcode tag for cowsay
	 * @var string
	 */
	private $shotcode_tag = 'cowsay';

	/**
	 * register plugin
	 * @return void
	 */
	function register() {
		add_action( 'plugins_loaded', array( $this, 'plugins_loaded' ) );
	}

	/**
	 * plugin loadded
	 * @return void
	 */
	public function plugins_loaded() {

		load_plugin_textdomain(
			'wp-cowsay',
			false,
			dirname( plugin_basename( __FILE__ ) ) . '/' . 'languages' . '/'
		);

		add_shortcode( $this->get_shortcode_tag(), array( $this, 'shortcode' ) );
	}

	/**
	 * get shortcode tag
	 * @return [filter]
	 */
	private function get_shortcode_tag() {
		return apply_filters( 'wp_cowsay_shortcode_tag', $this->shotcode_tag );
	}

	/**
	 * do shortcode to render to cowsay
	 * @param  Array $attrs   attributes of shortcode
	 * @param  string $content content of shortcode
	 * @return string          rendered HTML
	 */
	public function shortcode( $attrs, $content = '' ) {
		require_once( dirname( __FILE__ ) . '/vendor/autoload.php' );

		if ( $content === '' ) {
			$content = empty($attrs) ? '' : implode( ' ', array_values( $attrs ) );
		}

		$cow = \Cowsayphp\Farm::create( \Cowsayphp\Farm\Cow::class );
		return '<pre class="wp-cowsay">' . $cow->say($content) . '</pre>';
	}

}

// EOF
