import { useBlockProps, RichText } from '@wordpress/block-editor';

export default function save({ attributes }) {
    const { message } = attributes;
    const blockProps = useBlockProps.save();

    return (
        <div {...blockProps}>
            <button
                className="practice-pause__bell"
                aria-label="Ring the mindfulness bell"
                type="button"
            >
                <svg
                    width="40"
                    height="40"
                    viewBox="0 0 24 24"
                    fill="none"
                    xmlns="http://www.w3.org/2000/svg"
                    aria-hidden="true"
                >
                    <path
                        d="M12 2C12.55 2 13 2.45 13 3V3.27C15.93 3.97 18 6.64 18 9.82V15L20 17H4L6 15V9.82C6 6.64 8.07 3.97 11 3.27V3C11 2.45 11.45 2 12 2ZM10 20H14C14 21.1 13.1 22 12 22C10.9 22 10 21.1 10 20Z"
                        fill="currentColor"
                    />
                </svg>
            </button>
            <RichText.Content
                tagName="p"
                className="practice-pause__message"
                value={message}
            />
            <div className="practice-pause__breathing" aria-live="polite" hidden>
                <p className="practice-pause__breathing-text"></p>
            </div>
        </div>
    );
}
