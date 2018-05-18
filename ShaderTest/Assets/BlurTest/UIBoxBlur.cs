using UnityEngine;
using System.Collections;
using UnityEngine.UI;

namespace zwTech.Fx
{
    public class UIBoxBlur : MonoBehaviour
    {
        /// <summary>
        /// The material used to blur the render target of all cameras 
        /// </summary>
        [SerializeField]
        private Material _blurMaterial;

        /// <summary>
        /// All objects of this root will not be blurred
        /// </summary>
        [SerializeField]
        private GameObject _unblurredRoot;

        public GameObject UnblurredRoot
        {
            get
            {
                if (null == _unblurredRoot)
                {
                    _unblurredRoot = gameObject;
                }

                return _unblurredRoot;
            }
        }

        /// <summary>
        /// The unblurred root's canvas which will be disabled when render the blurred texture
        /// </summary>
        private Canvas _unblurredCanvas;

        public Canvas UnblurredCanvas
        {
            get
            {
                if (null == _unblurredCanvas)
                {
                    _unblurredCanvas = UnblurredRoot.GetComponent<Canvas>();

                    if (null == _unblurredCanvas)
                    {
                        _unblurredCanvas = UnblurredRoot.AddComponent<Canvas>();
                        _unblurredCanvas.overridePixelPerfect = false;
                        _unblurredCanvas.overrideSorting = false;
                    }
                }

                return _unblurredCanvas;
            }
        }

        private int _sampleWidth = 0;
        private int _sampleHeight = 0;
        private float _blurSize = 0.5f;
        private RawImage _blurredImage;
        private RenderTexture _blurredTexture;
        private bool _init = false;

        private void Init()
        {
            if (null == _blurMaterial)
            {
                Debug.LogWarning("The Blur Material is empty, please set it!", gameObject);
                return;
            }

            int maxResolution = _blurMaterial.GetInt("_MaxResolution");
            if (maxResolution <= 0)
            {
                return;
            }

            int downsample = (int)_blurMaterial.GetFloat("_Downsample");
            if (downsample <= 0)
            {
                downsample = 32;
            }

            _blurSize = _blurMaterial.GetFloat("_BlurSize");

            int minSide = Mathf.Min(Screen.width, Screen.height);
            maxResolution = Mathf.Min(minSide, maxResolution);

            // Caculate the sample width and height by screen size, max resolution and downsample
            _sampleWidth = Screen.width * maxResolution / minSide / downsample;
            _sampleHeight = Screen.height * maxResolution / minSide / downsample;

            // Get or add the raw image component used to render blurred image
            _blurredImage = GetComponent<RawImage>();
            if (null == _blurredImage)
            {
                _blurredImage = gameObject.AddComponent<RawImage>();
            }

        }

        private void OnDisable()
        {
            if (_blurredTexture != null)
            {
                _blurredTexture.Release();

                Destroy(_blurredTexture);

                _blurredTexture = null;
            }
        }

        private void FourTapCone(RenderTexture source, RenderTexture dest, int iteration)
        {
            float off = _blurSize * iteration + 0.5f;
            Graphics.BlitMultiTap(source, dest, _blurMaterial,
                new Vector2(-off, -off),
                new Vector2(-off, off),
                new Vector2(off, off),
                new Vector2(off, -off));
        }

        public void RenderImage()
        {
            if (!_init)
            {
                Init();
                _init = true;
            }

            if (_sampleWidth <= 0 || _sampleHeight <= 0 || null == _blurredImage || _blurSize <= 0f)
            {
                return;
            }

            // RenderTexture should with depth to render cross diff cameras
            RenderTexture rt = RenderTexture.GetTemporary(_sampleWidth, _sampleHeight, 24);

            // All cameras are sorted by depth
            Camera[] allCameras = Camera.allCameras;
            int allCamerasCount = Camera.allCamerasCount;

            // Unblurred canvas and current blurred image should not be renderred to render texture for blurring
            UnblurredCanvas.enabled = false;
            _blurredImage.enabled = false;

            for (int i = 0; i < allCamerasCount; i++)
            {
                Camera curCamera = allCameras[i];

                // Use all cameras which render to screen
                if (null == curCamera.targetTexture)
                {
                    curCamera.targetTexture = rt;
                    curCamera.Render();
                    curCamera.targetTexture = null;
                }
            }

            // Restore unblurred canvas and blurred image
            UnblurredCanvas.enabled = true;
            _blurredImage.enabled = true;

            // Blurring...
            for (int i = 0; i < 2; i++)
            {
                RenderTexture rt2 = RenderTexture.GetTemporary(_sampleWidth, _sampleHeight, 0);
                FourTapCone(rt, rt2, i);
                RenderTexture.ReleaseTemporary(rt);
                rt = rt2;
            }

            if (null == _blurredTexture)
            {
                _blurredTexture = new RenderTexture(_sampleWidth, _sampleHeight, 0);
                _blurredTexture.name = "UI Box Blur Texture";
                _blurredImage.texture = _blurredTexture;
            }

            // Blurred
            Graphics.Blit(rt, _blurredTexture);
            // Clear the render target at last
            Graphics.SetRenderTarget(null);

            RenderTexture.ReleaseTemporary(rt);
        }
    }
}