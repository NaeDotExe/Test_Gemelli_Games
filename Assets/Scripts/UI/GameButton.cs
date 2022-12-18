using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using DG.Tweening;

[RequireComponent(typeof(Button), typeof(EventTrigger))]
public class GameButton : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler, IPointerClickHandler
{
    #region Attributes
    [SerializeField] private float _onHoverScale = 1.2f;
    [SerializeField] private float _onClickScale = 1.2f;
    [SerializeField] private float _onClickDuration = 0.3f;
    [SerializeField] private int _onClickVibrato=7;
    [SerializeField] private int _onClickElasticity = 1;

    private Button _button = null;
    #endregion

    #region Events
    [HideInInspector]
    public UnityEvent OnClick = new UnityEvent();
    #endregion

    #region Methods
    private void Awake()
    {
        _button = GetComponent<Button>();
        if (_button == null)
        {
            Debug.LogError("No Component Error found.");
            return;
        }
    }
    private void Start()
    {
        _button.onClick.AddListener(OnClick.Invoke);
    }

    public void OnPointerClick(PointerEventData eventData)
    {
        transform.DOPunchScale(Vector3.one * _onClickScale, _onClickDuration, _onClickVibrato, _onClickElasticity);
    }
    public void OnPointerEnter(PointerEventData eventData)
    {
        transform.DOScale(_onHoverScale, 0.4f);
    }
    public void OnPointerExit(PointerEventData eventData)
    {
        transform.DOScale(1f, 0.4f);
    }
    #endregion
}
