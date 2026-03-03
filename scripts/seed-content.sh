#!/bin/bash
#
# Seed LearnDash demo content via WP-CLI.
# Idempotent — safe to run multiple times.
#
set -euo pipefail

# Helper: get post ID by slug and post type, or return empty string
get_post_id_by_slug() {
    local slug="$1"
    local post_type="$2"
    wp post list --post_type="$post_type" --name="$slug" --field=ID --format=ids 2>/dev/null || echo ""
}

echo "=== Seeding LearnDash demo content ==="

# -------------------------------------------------------
# Course: Foundations of Mindfulness
# -------------------------------------------------------
COURSE_SLUG="foundations-of-mindfulness"
COURSE_ID=$(get_post_id_by_slug "$COURSE_SLUG" "sfwd-courses")

if [ -z "$COURSE_ID" ]; then
    echo "Creating course: Foundations of Mindfulness..."
    COURSE_ID=$(wp post create \
        --post_type=sfwd-courses \
        --post_title="Foundations of Mindfulness" \
        --post_name="$COURSE_SLUG" \
        --post_status=publish \
        --post_content='<!-- wp:heading -->
<h2>Welcome to the Foundations of Mindfulness</h2>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>This course introduces the core practices of mindfulness as taught by Thich Nhat Hanh and the Plum Village tradition. Through four essential lessons, you will learn to cultivate presence, calm, and joy in your daily life.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Each lesson offers a guided practice that you can integrate into your routine — whether you have five minutes or an hour. No prior meditation experience is required.</p>
<!-- /wp:paragraph -->

<!-- wp:separator {"className":"is-style-wide"} -->
<hr class="wp-block-separator has-alpha-channel-opacity is-style-wide"/>
<!-- /wp:separator -->

<!-- wp:quote -->
<blockquote class="wp-block-quote"><p>The present moment is filled with joy and happiness. If you are attentive, you will see it.</p><cite>Thich Nhat Hanh</cite></blockquote>
<!-- /wp:quote -->' \
        --porcelain)
    echo "  Created course ID: $COURSE_ID"
else
    echo "  Course already exists (ID: $COURSE_ID)"
fi

# Set course to open access (no payment required)
wp eval "learndash_update_setting( $COURSE_ID, 'course_price_type', 'open' );" 2>/dev/null || true
wp eval "learndash_update_setting( $COURSE_ID, 'course_lesson_order', 'ASC' );" 2>/dev/null || true
wp eval "learndash_update_setting( $COURSE_ID, 'course_lesson_orderby', 'menu_order' );" 2>/dev/null || true

# -------------------------------------------------------
# Lesson 1: Sitting Meditation
# -------------------------------------------------------
LESSON1_SLUG="sitting-meditation"
LESSON1_ID=$(get_post_id_by_slug "$LESSON1_SLUG" "sfwd-lessons")

if [ -z "$LESSON1_ID" ]; then
    echo "Creating lesson: Sitting Meditation..."
    LESSON1_ID=$(wp post create \
        --post_type=sfwd-lessons \
        --post_title="Sitting Meditation" \
        --post_name="$LESSON1_SLUG" \
        --post_status=publish \
        --menu_order=1 \
        --post_content='<!-- wp:heading {"level":3} -->
<h3>The Art of Sitting</h3>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Sitting meditation is the foundation of mindfulness practice. Find a quiet place, sit comfortably with your back straight, and bring your attention to the present moment. There is nothing to do, nowhere to go — just sit and enjoy your breathing.</p>
<!-- /wp:paragraph -->

<!-- wp:quote -->
<blockquote class="wp-block-quote"><p>Sitting still, doing nothing, spring comes, and the grass grows by itself.</p><cite>Thich Nhat Hanh</cite></blockquote>
<!-- /wp:quote -->

<!-- wp:separator -->
<hr class="wp-block-separator has-alpha-channel-opacity"/>
<!-- /wp:separator -->

<!-- wp:heading {"level":4} -->
<h4>Practice Instructions</h4>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Begin with 10 minutes each morning. Sit on a cushion or chair with your spine upright but relaxed. Let your hands rest gently on your knees. Close your eyes or soften your gaze downward. Follow your breath — in and out — without trying to change it. When your mind wanders, gently return to the breath. This is the whole of the practice.</p>
<!-- /wp:paragraph -->' \
        --porcelain)
    echo "  Created lesson ID: $LESSON1_ID"
else
    echo "  Lesson already exists (ID: $LESSON1_ID)"
fi

# -------------------------------------------------------
# Lesson 2: Walking Meditation
# -------------------------------------------------------
LESSON2_SLUG="walking-meditation"
LESSON2_ID=$(get_post_id_by_slug "$LESSON2_SLUG" "sfwd-lessons")

if [ -z "$LESSON2_ID" ]; then
    echo "Creating lesson: Walking Meditation..."
    LESSON2_ID=$(wp post create \
        --post_type=sfwd-lessons \
        --post_title="Walking Meditation" \
        --post_name="$LESSON2_SLUG" \
        --post_status=publish \
        --menu_order=2 \
        --post_content='<!-- wp:heading {"level":3} -->
<h3>Walking as Meditation</h3>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Walking meditation brings mindfulness into motion. With each step, we arrive fully in the present moment. We walk not to arrive anywhere, but to be fully present with each step. Every step is a miracle — we are walking on the Earth, this beautiful planet.</p>
<!-- /wp:paragraph -->

<!-- wp:quote -->
<blockquote class="wp-block-quote"><p>Walk as if you are kissing the Earth with your feet.</p><cite>Thich Nhat Hanh</cite></blockquote>
<!-- /wp:quote -->

<!-- wp:separator -->
<hr class="wp-block-separator has-alpha-channel-opacity"/>
<!-- /wp:separator -->

<!-- wp:heading {"level":4} -->
<h4>Practice Instructions</h4>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Choose a quiet path, indoors or outdoors, about 30 feet long. Stand still for a moment, feeling your feet on the ground. Begin walking slowly, coordinating your steps with your breathing. Perhaps two or three steps for each in-breath, and two or three steps for each out-breath. Smile gently as you walk. There is nowhere to arrive — each step is your destination.</p>
<!-- /wp:paragraph -->' \
        --porcelain)
    echo "  Created lesson ID: $LESSON2_ID"
else
    echo "  Lesson already exists (ID: $LESSON2_ID)"
fi

# -------------------------------------------------------
# Lesson 3: Mindful Breathing
# -------------------------------------------------------
LESSON3_SLUG="mindful-breathing"
LESSON3_ID=$(get_post_id_by_slug "$LESSON3_SLUG" "sfwd-lessons")

if [ -z "$LESSON3_ID" ]; then
    echo "Creating lesson: Mindful Breathing..."
    LESSON3_ID=$(wp post create \
        --post_type=sfwd-lessons \
        --post_title="Mindful Breathing" \
        --post_name="$LESSON3_SLUG" \
        --post_status=publish \
        --menu_order=3 \
        --post_content='<!-- wp:heading {"level":3} -->
<h3>Breathing with Awareness</h3>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Mindful breathing is the bridge between body and mind. When we breathe consciously, we bring our scattered mind back to our body. In just three breaths, we can restore our calm, our peace, and our joy. The breath is always available to us, a faithful friend we can return to at any moment.</p>
<!-- /wp:paragraph -->

<!-- wp:quote -->
<blockquote class="wp-block-quote"><p>Breathing in, I calm my body. Breathing out, I smile. Dwelling in the present moment, I know this is a wonderful moment.</p><cite>Thich Nhat Hanh</cite></blockquote>
<!-- /wp:quote -->

<!-- wp:separator -->
<hr class="wp-block-separator has-alpha-channel-opacity"/>
<!-- /wp:separator -->

<!-- wp:heading {"level":4} -->
<h4>Practice Instructions</h4>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>You can practice mindful breathing anywhere — at your desk, on the bus, or lying in bed. Simply bring your attention to your breath. Breathe in and know you are breathing in. Breathe out and know you are breathing out. If you like, place one hand on your belly and feel it rise and fall. Use gathas (short verses) to guide your attention: "In" on the in-breath, "Out" on the out-breath. Start with five minutes and let the practice grow naturally.</p>
<!-- /wp:paragraph -->' \
        --porcelain)
    echo "  Created lesson ID: $LESSON3_ID"
else
    echo "  Lesson already exists (ID: $LESSON3_ID)"
fi

# -------------------------------------------------------
# Lesson 4: Deep Relaxation
# -------------------------------------------------------
LESSON4_SLUG="deep-relaxation"
LESSON4_ID=$(get_post_id_by_slug "$LESSON4_SLUG" "sfwd-lessons")

if [ -z "$LESSON4_ID" ]; then
    echo "Creating lesson: Deep Relaxation..."
    LESSON4_ID=$(wp post create \
        --post_type=sfwd-lessons \
        --post_title="Deep Relaxation" \
        --post_name="$LESSON4_SLUG" \
        --post_status=publish \
        --menu_order=4 \
        --post_content='<!-- wp:heading {"level":3} -->
<h3>Total Relaxation of Body and Mind</h3>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Deep relaxation is the practice of scanning through the body with awareness, releasing tension and sending love to each part. In Plum Village, we practice this daily. It is a gift we give to our body — a chance to rest, to heal, and to be embraced by the Earth beneath us.</p>
<!-- /wp:paragraph -->

<!-- wp:quote -->
<blockquote class="wp-block-quote"><p>Feelings come and go like clouds in a windy sky. Conscious breathing is my anchor.</p><cite>Thich Nhat Hanh</cite></blockquote>
<!-- /wp:quote -->

<!-- wp:separator -->
<hr class="wp-block-separator has-alpha-channel-opacity"/>
<!-- /wp:separator -->

<!-- wp:heading {"level":4} -->
<h4>Practice Instructions</h4>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Lie down on your back in a comfortable position, arms at your sides, palms facing up. Close your eyes and become aware of your whole body. Begin at the top of your head and slowly move your attention downward — forehead, eyes, cheeks, jaw, neck, shoulders, arms, hands. With each area, breathe in and send your awareness there; breathe out and release any tension. Continue through your chest, belly, hips, legs, and feet. Allow 15 to 20 minutes for the full practice. Rest in stillness as long as you wish.</p>
<!-- /wp:paragraph -->' \
        --porcelain)
    echo "  Created lesson ID: $LESSON4_ID"
else
    echo "  Lesson already exists (ID: $LESSON4_ID)"
fi

# -------------------------------------------------------
# Associate lessons to course
# -------------------------------------------------------
echo "Associating lessons to course..."
for LESSON_ID in $LESSON1_ID $LESSON2_ID $LESSON3_ID $LESSON4_ID; do
    wp eval "learndash_update_setting( $LESSON_ID, 'course', $COURSE_ID );" 2>/dev/null || true
done

# Flush rewrite rules so LearnDash URLs work
wp rewrite flush 2>/dev/null || true

# -------------------------------------------------------
# Portfolio Skills Page
# -------------------------------------------------------
PORTFOLIO_SLUG="portfolio"
PORTFOLIO_ID=$(get_post_id_by_slug "$PORTFOLIO_SLUG" "page")

if [ -z "$PORTFOLIO_ID" ]; then
    echo "Creating page: Technical Skills Portfolio..."
    PORTFOLIO_ID=$(wp post create \
        --post_type=page \
        --post_title="Technical Skills Portfolio" \
        --post_name="$PORTFOLIO_SLUG" \
        --post_status=publish \
        --post_content='<!-- wp:paragraph -->
<p>This site is a working demo built for the <strong>Senior Web Developer</strong> role at the Thich Nhat Hanh Foundation. Every feature listed below runs on this site — built with WordPress, LearnDash, custom PHP, JavaScript, and modern deployment practices.</p>
<!-- /wp:paragraph -->

<!-- wp:separator {"className":"is-style-wide"} -->
<hr class="wp-block-separator has-alpha-channel-opacity is-style-wide"/>
<!-- /wp:separator -->

<!-- wp:heading -->
<h2>Skills Demonstrated</h2>
<!-- /wp:heading -->

<!-- wp:heading {"level":3} -->
<h3>Custom Theme Development</h3>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Block theme with Full Site Editing templates, <code>theme.json</code> design system (8 colors, 2 font families, 5 spacing sizes), and LearnDash template overrides (<code>course.php</code>, <code>lesson.php</code>, <code>course_list_template.php</code>).</p>
<!-- /wp:paragraph -->

<!-- wp:heading {"level":3} -->
<h3>Custom Plugin Development</h3>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Three custom Gutenberg blocks in a single plugin: <strong>Dharma Talk</strong> (static card with RichText), <strong>Practice Pause</strong> (interactive breathing exercise with vanilla JS), and <strong>Course Grid</strong> (dynamic ServerSideRender with PHP render callback).</p>
<!-- /wp:paragraph -->

<!-- wp:heading {"level":3} -->
<h3>PHP</h3>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>LearnDash template overrides using <code>learndash_get_course_steps()</code>, <code>learndash_is_lesson_complete()</code>, and <code>learndash_course_status()</code>. Server-side block rendering with <code>register_block_type()</code> render callbacks. WordPress hooks and filters for template routing.</p>
<!-- /wp:paragraph -->

<!-- wp:heading {"level":3} -->
<h3>HTML &amp; CSS</h3>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Block templates using WordPress design tokens (<code>var(--wp--preset--color--forest-green)</code>). Responsive grid layouts. Accessible markup with semantic HTML5 elements.</p>
<!-- /wp:paragraph -->

<!-- wp:heading {"level":3} -->
<h3>SASS</h3>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Each block has separate <code>style.scss</code> (frontend) and <code>editor.scss</code> (editor-only) files, compiled via <code>@wordpress/scripts</code>. BEM naming convention throughout.</p>
<!-- /wp:paragraph -->

<!-- wp:heading {"level":3} -->
<h3>JavaScript</h3>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Vanilla JS breathing exercise with timed state machine (Practice Pause <code>view.js</code>). React editor components using <code>@wordpress/block-editor</code>, <code>InspectorControls</code>, <code>RangeControl</code>, <code>ToggleControl</code>. Dynamic previews via <code>@wordpress/server-side-render</code>.</p>
<!-- /wp:paragraph -->

<!-- wp:heading {"level":3} -->
<h3>LearnDash</h3>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Demo course with 4 lessons seeded via WP-CLI. Custom course and lesson templates with progress tracking, breadcrumbs, and prev/next navigation. Dynamic Course Grid block querying <code>sfwd-courses</code> post type. Course-lesson relationships via <code>learndash_update_setting()</code>.</p>
<!-- /wp:paragraph -->

<!-- wp:heading {"level":3} -->
<h3>BuddyPress</h3>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Installed with theme support declared. Community features planned for the next iteration.</p>
<!-- /wp:paragraph -->

<!-- wp:heading {"level":3} -->
<h3>Git &amp; DevOps</h3>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Version-controlled WordPress workflow. Reproducible local setup via Docker Compose + WP-CLI. Production deployment on Railway with managed MySQL. One-directional content pipeline: <code>make export</code> → <code>make import-prod</code> → <code>make deploy</code>.</p>
<!-- /wp:paragraph -->

<!-- wp:heading {"level":3} -->
<h3>Gutenberg</h3>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Three custom blocks (static, interactive, dynamic). Block patterns for reusable content layouts. Full Site Editing templates with <code>wp:template-part</code>. <code>theme.json</code> design system for consistent styling.</p>
<!-- /wp:paragraph -->

<!-- wp:separator {"className":"is-style-wide"} -->
<hr class="wp-block-separator has-alpha-channel-opacity is-style-wide"/>
<!-- /wp:separator -->

<!-- wp:heading -->
<h2>Architecture</h2>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p><strong>Local development:</strong> Docker Compose with 4 services (WordPress, MariaDB, WP-CLI, Adminer). Theme and plugin bind-mounted for live editing.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>Production:</strong> Railway with managed MySQL. WordPress container runs Apache as a single process (no supervisord). Uploads stored on a persistent volume. WordPress core and plugins baked into the Docker image at build time.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>Content pipeline:</strong> Content is authored locally, exported via <code>make export</code>, pushed to production with <code>make import-prod</code> (direct MySQL connection to Railway), and deployed with <code>make deploy</code> (railway up --no-gitignore).</p>
<!-- /wp:paragraph -->

<!-- wp:separator {"className":"is-style-wide"} -->
<hr class="wp-block-separator has-alpha-channel-opacity is-style-wide"/>
<!-- /wp:separator -->

<!-- wp:heading -->
<h2>Links</h2>
<!-- /wp:heading -->

<!-- wp:list -->
<ul><li><a href="https://github.com/bbuchalter/plum-village-portfolio">GitHub Repository</a></li><li><a href="https://plum-village-portfolio.buchalter.dev">Production Site</a></li><li><a href="/courses/foundations-of-mindfulness">Demo Course: Foundations of Mindfulness</a></li></ul>
<!-- /wp:list -->' \
        --porcelain)
    echo "  Created portfolio page ID: $PORTFOLIO_ID"
else
    echo "  Portfolio page already exists (ID: $PORTFOLIO_ID)"
fi

echo ""
echo "=== Seed content complete ==="
echo "  Course: Foundations of Mindfulness (ID: $COURSE_ID)"
echo "  Lessons: $LESSON1_ID, $LESSON2_ID, $LESSON3_ID, $LESSON4_ID"
echo "  Portfolio page: $PORTFOLIO_ID"
echo ""
echo "  View course at: /courses/foundations-of-mindfulness"
echo "  View portfolio at: /portfolio"
