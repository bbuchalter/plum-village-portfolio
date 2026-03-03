/**
 * Practice Pause — frontend interactivity (vanilla JS, no React).
 *
 * When a visitor clicks the bell button the block cycles through three rounds
 * of "Breathing in..." (4 s) and "Breathing out..." (6 s), then hides the
 * breathing prompt again.
 */
(function () {
    'use strict';

    var ROUNDS = 3;
    var INHALE_MS = 4000;
    var EXHALE_MS = 6000;

    function initBlock(wrapper) {
        var bell = wrapper.querySelector('.practice-pause__bell');
        var breathingContainer = wrapper.querySelector('.practice-pause__breathing');
        var breathingText = wrapper.querySelector('.practice-pause__breathing-text');

        if (!bell || !breathingContainer || !breathingText) {
            return;
        }

        var running = false;

        bell.addEventListener('click', function () {
            if (running) return;
            running = true;

            wrapper.classList.add('ringing');
            breathingContainer.hidden = false;
            breathingContainer.classList.add('visible');

            runBreathingCycle(0);
        });

        function runBreathingCycle(round) {
            if (round >= ROUNDS) {
                finish();
                return;
            }

            // Breathing in
            breathingText.textContent = 'Breathing in\u2026';
            breathingText.classList.remove('fade-out');
            breathingText.classList.add('fade-in');

            setTimeout(function () {
                // Breathing out
                breathingText.classList.remove('fade-in');
                breathingText.classList.add('fade-out');

                setTimeout(function () {
                    breathingText.textContent = 'Breathing out\u2026';
                    breathingText.classList.remove('fade-out');
                    breathingText.classList.add('fade-in');

                    setTimeout(function () {
                        breathingText.classList.remove('fade-in');
                        breathingText.classList.add('fade-out');

                        setTimeout(function () {
                            runBreathingCycle(round + 1);
                        }, 500);
                    }, EXHALE_MS);
                }, 500);
            }, INHALE_MS);
        }

        function finish() {
            breathingContainer.classList.remove('visible');
            wrapper.classList.remove('ringing');

            setTimeout(function () {
                breathingContainer.hidden = true;
                breathingText.textContent = '';
                breathingText.classList.remove('fade-in', 'fade-out');
                running = false;
            }, 600);
        }
    }

    // Initialise every Practice Pause block on the page.
    document.querySelectorAll('.wp-block-plum-village-practice-pause').forEach(initBlock);
})();
