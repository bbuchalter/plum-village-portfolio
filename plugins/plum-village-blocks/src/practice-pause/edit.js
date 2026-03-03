import { __ } from '@wordpress/i18n';
import { useBlockProps, RichText } from '@wordpress/block-editor';

import './editor.scss';

export default function Edit({ attributes, setAttributes }) {
    const { message } = attributes;
    const blockProps = useBlockProps();

    return (
        <div {...blockProps}>
            <div className="practice-pause__bell-icon" aria-hidden="true">
                <svg
                    width="48"
                    height="48"
                    viewBox="0 0 24 24"
                    fill="none"
                    xmlns="http://www.w3.org/2000/svg"
                >
                    <path
                        d="M12 2C12.55 2 13 2.45 13 3V3.27C15.93 3.97 18 6.64 18 9.82V15L20 17H4L6 15V9.82C6 6.64 8.07 3.97 11 3.27V3C11 2.45 11.45 2 12 2ZM10 20H14C14 21.1 13.1 22 12 22C10.9 22 10 21.1 10 20Z"
                        fill="#2D5F2D"
                    />
                </svg>
            </div>
            <RichText
                tagName="p"
                className="practice-pause__message"
                value={message}
                onChange={(value) => setAttributes({ message: value })}
                placeholder={__(
                    'Enter a mindfulness message...',
                    'plum-village-blocks'
                )}
            />
            <p className="practice-pause__editor-note">
                {__(
                    'Click the bell on the frontend to practice.',
                    'plum-village-blocks'
                )}
            </p>
        </div>
    );
}
