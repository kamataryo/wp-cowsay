<?php

class WPCowsay_Test extends WP_UnitTestCase {

	/**
	 * shortcode execution finished successfully with inner content.
	 * It should render to say Moo!.
	 * \(oo\) <- this is escaped cow's face.
 	 * @test
	 */
	public function shortcode_test_success_without_attr() {
		$this->assertRegExp(
			'/^(<pre class="wp-cowsay">).*(Moo!).*(\(oo\)).*(<\/pre>)$/s',
			do_shortcode( '[cowsay]Moo![/cowsay]' )
		);
	}

	/**
	 * shortcode execution finished successfully with attribute-like content not-escaped.
	 * It should render to say Moo.
	 * @test
	 */
	public function shortcode_test_success_with_attr_no_esc() {
		$this->assertRegExp(
			'/^(<pre class="wp-cowsay">).*(Moo).*(\(oo\)).*(<\/pre>)$/s',
			do_shortcode( '[cowsay Moo]' )
		);
	}

	/**
	 * shortcode execution finished successfully with attribute-like content.
	 * It should render to say Moo Moo.
	 * @test
	 */
	public function shortcode_test_success_with_attrs() {
		$this->assertRegExp(
			'/^(<pre class="wp-cowsay">).*(Moo Moo).*(\(oo\)).*(<\/pre>)$/s',
			do_shortcode( '[cowsay Moo Moo]' )
		);
	}

	/**
	 * shortcode execution finished successfully with real content and attribute-like content.
	 * The former should be superior.
	 * @test
	 */
	public function shortcode_test_success_with_attr_and_content() {
		$this->assertRegExp(
			'/^(<pre class="wp-cowsay">).*(Voo).*(\(oo\)).*(<\/pre>)$/s',
			do_shortcode( '[cowsay Moo]Voo[/cowsay]' )
		);
	}
}
