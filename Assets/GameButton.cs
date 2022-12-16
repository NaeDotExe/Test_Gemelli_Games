using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using DG.Tweening;

[RequireComponent(typeof(Button), typeof(EventTrigger))]
public class GameButton : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler, IPointerClickHandler
{
    #region Attributes
    [SerializeField] private float _onHoverScale = 1.2f;

    private Button _button = null;
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

    public void OnPointerClick(PointerEventData eventData)
    {
        transform.DOPunchScale(Vector3.one * 1.2f, 0.3f, 7, 1);
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
