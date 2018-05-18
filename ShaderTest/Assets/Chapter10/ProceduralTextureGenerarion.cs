using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class ProceduralTextureGenerarion : MonoBehaviour
{

    public Material material = null;

#region Material Properties

    [SerializeField,SetProperty("textureWidth")]
    private int _textureWidth = 512;
    public int TextureWidth {
        get { return _textureWidth; }
        set
        {
            _textureWidth = value;
            //setmat
        }
    }

    [SerializeField, SetProperty("backgroundColor")]
    private Color _backGrountColor = Color.white;

    public Color BackGroundColor
    {
        get { return _backGrountColor;}
        set
        {
            _backGrountColor = value;
            //setmat
        }
    }

    [SerializeField, SetProperty("circleColor")]
    private Color _circleColor = Color.yellow;

    public Color CircleColor
    {
        get { return _circleColor;}
        set
        {
            _circleColor = value;
            //setmat
        }
    }

    [SerializeField, SetProperty("blurFactor")]
    private float _blurFactor = 2.0f;

    public float BlurFactor
    {
        get { return _blurFactor; }
        set
        {
            _blurFactor = value;
            //setmat
            _UpdataMaterial();
        }
    }

    private void _UpdataMaterial()
    {
        throw new System.NotImplementedException();
    }

    private Texture2D _generatedTexture = null;

    #endregion
    // Use this for initialization
	void Start () {
	    
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
